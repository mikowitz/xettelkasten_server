defmodule XettelkastenServer do
  @notes_directory Application.get_env(:xettelkasten_server, :notes_directory)

  def notes_directory, do: @notes_directory
end
