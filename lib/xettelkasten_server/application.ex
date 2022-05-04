defmodule XettelkastenServer.Application do
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Application.ensure_started(:file_system)

    children = [
      {XettelkastenServer.NoteWatcher, []},
      {Plug.Cowboy,
       scheme: :http, plug: XettelkastenServer.Router, options: [port: cowboy_port()]}
    ]

    children = case Application.get_env(:xettelkasten_server, :auto_commit, false) do
      true -> [{XettelkastenServer.GitWatcher, []} | children]
      false -> children
    end

    Logger.info("Starting Xettelkasten server on port #{cowboy_port()}")

    opts = [strategy: :one_for_one, name: XettelkastenServer.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp cowboy_port do
    Application.get_env(:xettelkasten_server, :cowboy_port, 8080)
  end
end
