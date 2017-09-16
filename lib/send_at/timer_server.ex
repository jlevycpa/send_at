defmodule SendAt.TimerServer do
  require Logger
  use GenServer

  # API

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def add(dest, msg, time) do
    GenServer.call(__MODULE__, {:add, dest, msg, time})
  end

  # Callbacks

  def init(_) do
    :erlang.monitor(:time_offset, :clock_service)    
    {:ok, []}
  end

  def handle_call({:add, dest, msg, time}, _from, state) do
    {ref, _, _, _} = timer = set_timer(dest, msg, time)
    state = [timer | state]
    Logger.debug("Added timer. New state: #{inspect(state)}")
    {:reply, ref, state}
  end

  def handle_info({:timeout, ref, :timeout}, state) do
    case List.keytake(state, ref, 0) do
      nil -> {:noreply, state} # Ignore a timer that was already canceled or reset
      {timer, new_state} -> 
        process_timer(timer)
        {:noreply, new_state}
    end
  end
  
  def handle_info({:CHANGE, _, :time_offset, :clock_service, _}, state) do
    Logger.debug("Time warp has occured")
    state = reset_all_timers(state)
    {:noreply, state}
  end

  # Private

  defp set_timer(dest, msg, time) do
    Logger.debug("Time offset is #{System.time_offset(:millisecond)}")
    monotonic = time - System.time_offset(:millisecond)
    ref = :erlang.start_timer(monotonic, self(), :timeout, abs: true)
    {ref, dest, msg, time}
  end

  defp process_timer({_ref, dest, msg, _time}) do
    Logger.debug("Sending message")
    send(dest, msg)
  end

  defp reset_all_timers(state) do
    Enum.map(state, &reset_timer/1)
    |> Enum.reject(&is_nil/1)
  end

  defp reset_timer({ref, dest, msg, time} = timer) do
    :erlang.cancel_timer(ref)
    try do
      set_timer(dest, msg, time)
    rescue _e in ArgumentError ->
      Logger.debug("Could not reset timer. New montonic time would be negative. Sending message now.")
      process_timer(timer)
      nil
    end
  end
    
end

