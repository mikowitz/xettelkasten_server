defmodule XettelkastenServer.NotesTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.{Note, Notes}

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
      assert %Note{
               path: "test/support/notes/simple.md",
               slug: "simple",
               title: "A simple note"
             } = Notes.get("simple")
    end

    test "when the note doesn't exist" do
      refute Notes.get("not_a_note")
    end
  end

  describe "with_backlinks_to" do
    test "returns a list of notes that link to the given slug" do
      notes = Notes.with_backlinks_to("backlinks")

      assert notes == [note_from_filepath("with_neither_header_nor_h1")]
    end
  end

  def note_from_filepath(filepath) do
    path = Path.join(XettelkastenServer.notes_directory(), filepath <> ".md")

    Note.from_path(path)
  end
end
