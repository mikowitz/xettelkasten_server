import Config

config :xettelkasten_server, cowboy_port: 8088
config :xettelkasten_server, notes_directory: "test/support/notes"

config :logger, level: :error

config :xettelkasten_server,
  file_watcher_delay_ms: System.get_env("FILE_WATCHER_DELAY_MS", "100") |> String.to_integer()

config :mix_test_watch,
  tasks: [
    "test",
    "credo --all --strict"
  ]
