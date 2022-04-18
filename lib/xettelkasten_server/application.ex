defmodule XettelkastenServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: XettelkastenServer.Worker.start_link(arg)
      # {XettelkastenServer.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: XettelkastenServer.Router, port: cowboy_port()}
    ]

    Logger.info("Starting XettelkastenServer on port #{cowboy_port()}")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XettelkastenServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:xettelkasten_server, :cowboy_port)
end
