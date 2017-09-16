defmodule SendAt.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    children = case :erlang.system_info(:time_warp_mode) do
      :multi_time_warp -> [SendAt.TimerServer]
      :no_time_warp -> []
      :single_time_warp -> []
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SendAt.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
