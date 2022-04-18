defmodule XettelkastenServer.NoteTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.Note

  test "from_path" do
    path = note_path("simple.md")

    assert Note.from_path(path) == %Note{
             path: path,
             slug: "simple",
             title: "Simple"
           }
  end

  test "from slug" do
    assert Note.from_slug("basic_note") == %Note{
             path: note_path("basic_note.md"),
             slug: "basic_note",
             title: "Basic Note"
           }
  end

  describe "read" do
    test "returns Earkmark tuple for an existing note" do
      note =
        "simple.md"
        |> note_path()
        |> Note.from_path()

      html = Note.read(note)

      assert html =~ ~r"<h1>\nA simple note</h1>"
    end

    test "returns posix error for a missing note" do
      note =
        "not_a_note.md"
        |> note_path()
        |> Note.from_path()

      assert Note.read(note) == {:error, :enoent}
    end
  end

  defp note_path(filename) do
    Path.join(
      XettelkastenServer.notes_directory(),
      filename
    )
  end
end
