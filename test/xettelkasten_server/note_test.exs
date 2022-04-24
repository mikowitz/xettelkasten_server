defmodule XettelkastenServer.NoteTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.{Backlink, Note}

  describe "from_path" do
    test "unnested" do
      path = note_path("simple.md")

      assert %Note{
               path: ^path,
               slug: "simple",
               title: "A simple note",
               tags: [],
               html: "<h1>\nA simple note</h1>\n<p>\nHello there!</p>\n",
               backlinks: []
             } = Note.from_path(path)
    end

    test "when the file doesn't exist" do
      path = note_path("nested/simple.md")

      assert Note.from_path(path) == nil
    end

    test "with header metadata" do
      path = note_path("with_header.md")

      backlink_path = note_path("backlink.md")

      assert %Note{
               path: ^path,
               slug: "with_header",
               title: "My Cool Note",
               tags: ~w(#awesome #more_tags #prettycool #sweet #tags),
               backlinks: [
                 %Backlink{
                   missing: true,
                   path: ^backlink_path,
                   text: "backlink",
                   slug: "backlink"
                 }
               ]
             } = Note.from_path(path)
    end

    test "with header metadata and an h1 tag" do
      path = note_path("with_header_and_h1.md")

      assert %Note{
               path: ^path,
               slug: "with_header_and_h1",
               title: "Hello"
             } = Note.from_path(path)
    end
  end

  defp note_path(filename) do
    Path.join(
      XettelkastenServer.notes_directory(),
      filename
    )
  end
end
