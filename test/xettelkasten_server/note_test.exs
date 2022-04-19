defmodule XettelkastenServer.NoteTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.Note

  describe "from_path" do
    test "unnested" do
      path = note_path("simple.md")

      assert Note.from_path(path) == %Note{
               path: path,
               slug: "simple",
               title: "Simple"
             }
    end

    test "nested" do
      path = note_path("nested/simple.md")

      assert Note.from_path(path) == %Note{
               path: path,
               slug: "nested.simple",
               title: "Nested/Simple"
             }
    end
  end

  describe "from slug" do
    test "unnested" do
      assert Note.from_slug("basic_note") == %Note{
               path: note_path("basic_note.md"),
               slug: "basic_note",
               title: "Basic Note"
             }
    end

    test "nested" do
      assert Note.from_slug("deeply.nested.basic_note") == %Note{
               path: note_path("deeply/nested/basic_note.md"),
               slug: "deeply.nested.basic_note",
               title: "Deeply/Nested/Basic Note"
             }
    end
  end

  describe "from title" do
    test "unnested" do
      assert Note.from_title("GREAT Note") == %Note{
               path: note_path("great_note.md"),
               slug: "great_note",
               title: "GREAT Note"
             }
    end

    test "nested" do
      assert Note.from_title("GREAT/Note") == %Note{
               path: note_path("great/note.md"),
               slug: "great.note",
               title: "GREAT/Note"
             }
    end
  end

  describe "read" do
    test "returns Earmark tuple for an existing note" do
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

    test "correctly parses markdown with tags" do
      note =
        "tag.md"
        |> note_path()
        |> Note.from_path()

      html = Note.read(note)

      {:ok, doc} = Floki.parse_document(html)

      [{"h1", _, [header]}] = Floki.find(doc, "h1")
      assert String.trim(header) == "Tag"

      [{"a", attrs, [text]}] = Floki.find(doc, "a.tag")

      assert String.trim(text) == "#tag"
      assert {"href", "/?tag=tag"} in attrs
      assert {"class", "tag"} in attrs
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
