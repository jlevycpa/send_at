defmodule SendAt do
  alias SendAt.TimerServer
  @moduledoc """
  Documentation for SendAt.
  """

  @doc """

  """
  def send_at(dest, msg, %DateTime{} = time) do
    unix_time = DateTime.to_unix(time, :millisecond)    
    send_at(dest, msg, unix_time, :millisecond)
  end

  def send_at(dest, msg, time, unit \\ :second) when is_integer(time) do
    mode = :erlang.system_info(:time_warp_mode)
    ms = System.convert_time_unit(time, unit, :millisecond)
    do_send_at(dest, msg, ms, mode)
  end

  defp do_send_at(dest, msg, time, :multi_time_warp) do
    TimerServer.add(dest, msg, time)
  end

  defp do_send_at(dest, msg, time, _) do
    monotonic = time - System.time_offset(:millisecond)
    Process.send_after(dest, msg, monotonic, abs: true)
  end


    
end
