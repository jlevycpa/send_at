defmodule SendAt.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    do_start(:erlang.system_info(:time_warp_mode))
  end
  

  defp do_start(:multi_time_warp) do
    children = [SendAt.TimerServer]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SendAt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp do_start(_) do
    {:ok, self()}
  end


end
