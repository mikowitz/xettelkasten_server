defmodule XettelkastenServer do
  @moduledoc false

  @notes_directory Application.compile_env(:xettelkasten_server, :notes_directory)

  def notes_directory, do: @notes_directory
end
