import Config

config :xettelkasten_server, cowboy_port: 8088
config :xettelkasten_server, notes_directory: "test/support/notes"

config :logger, level: :error

config :mix_test_watch,
  tasks: [
    "test",
    "credo --all --strict"
  ]
