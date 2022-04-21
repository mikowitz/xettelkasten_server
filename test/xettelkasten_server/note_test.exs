defmodule XettelkastenServer.NoteTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.Note

  describe "from_path" do
    test "unnested" do
      path = note_path("simple.md")

      assert Note.from_path(path) == %Note{
               path: path,
               slug: "simple",
               title: "Simple",
               markdown: "# A simple note\n\nHello there!\n"
             }
    end

    test "when the file doesn't exist" do
      path = note_path("nested/simple.md")

      assert Note.from_path(path) == nil
    end

    test "with header metadata" do
      path = note_path("with_header.md")

      assert Note.from_path(path) == %Note{
               path: path,
               slug: "with_header",
               title: "My Cool Note",
               tags: ~w(#awesome #more_tags #prettycool #sweet #tags),
               markdown:
                 "\nThis is just the rest of the post with a [[backlink]]\n\nand some #tags #more_tags #awesome\n"
             }
    end

    test "with header metadata and an h1 tag" do
      path = note_path("with_header_and_h1.md")

      assert Note.from_path(path) == %Note{
               path: path,
               slug: "with_header_and_h1",
               title: "Hello",
               tags: [],
               markdown: "# Foo bar\n"
             }
    end
  end

  describe "parse_markdown" do
    test "returns Earmark tuple for an existing note" do
      note =
        "simple.md"
        |> note_path()
        |> Note.from_path()

      html = Note.parse_markdown(note)

      {:ok, doc} = Floki.parse_document(html)

      [{"h1", _, [header]}] = Floki.find(doc, "h1")
      assert String.trim(header) == "A simple note"
    end

    test "correctly parses markdown with backlinks" do
      note =
        "simple_backlink.md"
        |> note_path()
        |> Note.from_path()

      html = Note.parse_markdown(note)

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

      html = Note.parse_markdown(note)

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

      assert Note.parse_markdown(note) == {:error, :enoent}
    end
  end

  defp note_path(filename) do
    Path.join(
      XettelkastenServer.notes_directory(),
      filename
    )
  end
end
