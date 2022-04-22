defmodule XettelkastenServer.NotesTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.Notes
  alias XettelkastenServer.Note

  describe "all" do
    test "untagged" do
      assert Notes.all() == [
               note_from_filepath("backlinks"),
               note_from_filepath("nested/bird"),
               note_from_filepath("nested/no_title"),
               note_from_filepath("simple"),
               note_from_filepath("simple_backlink"),
               note_from_filepath("tag"),
               note_from_filepath("with_header"),
               note_from_filepath("with_header_and_h1"),
               note_from_filepath("with_neither_header_nor_h1")
             ]
    end

    test "tagged" do
      assert Notes.all(tag: "tag") == [
               note_from_filepath("tag")
             ]
    end
  end

  describe "get" do
    test "when the note exists" do
      assert Notes.get("simple") == %Note{
               path: "test/support/notes/simple.md",
               slug: "simple",
               title: "A simple note",
               markdown: "# A simple note\n\nHello there!\n"
             }
    end

    test "when the note doesn't exist" do
      refute Notes.get("not_a_note")
    end
  end

  describe "find_note_from_link_text" do
    test "when the text parses into a note path" do
      assert Notes.find_note_from_link_text("Nested / Bird") == Notes.get("nested.bird")
    end

    test "when the text parses to a note's title" do
      assert Notes.find_note_from_link_text("I'm a bird") == Notes.get("nested.bird")
    end

    test "when no note can be found" do
      refute Notes.find_note_from_link_text("No chance in hell")
    end
  end

  def note_from_filepath(filepath) do
    path = Path.join(XettelkastenServer.notes_directory(), filepath <> ".md")

    Note.from_path(path)
  end
end
