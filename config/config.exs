import Config

config :xettelkasten_server, cowboy_port: 8080
config :xettelkasten_server, notes_directory: "priv/notes"

import_config("#{Mix.env()}.exs")
