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

  test "from title" do
    assert Note.from_title("GREAT Note") == %Note{
             path: note_path("great_note.md"),
             slug: "great_note",
             title: "GREAT Note"
           }
  end

  describe "read" do
    test "returns Earkmark tuple for an existing note" do
      note =
        "simple.md"
        |> note_path()
        |> Note.from_path()

      html = Note.read(note)

      {:ok, doc} = Floki.parse_document(html)

      [{"h1", _, [header]}] = Floki.find(doc, "h1")
      assert String.trim(header) == "A simple note"
    end

    test "correctly parses markdown with backlinks" do
      note =
        "simple_backlink.md"
        |> note_path()
        |> Note.from_path()

      html = Note.read(note)

      {:ok, doc} = Floki.parse_document(html)

      [{"h1", _, [header]}] = Floki.find(doc, "h1")
      assert String.trim(header) == "Simple backlink"

      [{"a", attrs, [text]}] = Floki.find(doc, "a")

      assert attrs == [{"href", "/very_simple"}]
      assert String.trim(text) == "very simple"
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
