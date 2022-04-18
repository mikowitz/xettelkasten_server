defmodule XettelkastenServer.NoteTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.Note

  test "from_path" do
    path = note_path("simple.md")

    assert Note.from_path(path) == %Note{
      path: path,
      slug: "simple",
      title: "Simple",
    }
  end

  defp note_path(filename) do
    Path.join(
      XettelkastenServer.notes_directory(),
      filename
    )
  end
end
