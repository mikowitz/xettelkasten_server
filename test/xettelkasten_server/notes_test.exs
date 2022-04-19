defmodule XettelkastenServer.NotesTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.Notes
  alias XettelkastenServer.Note

  describe "all" do
    test "untagged" do
      assert Notes.all() == [
               Note.from_slug("backlinks"),
               Note.from_slug("nested.bird"),
               Note.from_slug("simple"),
               Note.from_slug("simple_backlink"),
               Note.from_slug("tag")
             ]
    end

    test "tagged" do
      assert Notes.all(tag: "tag") == [
               Note.from_slug("tag")
             ]
    end
  end

  describe "get" do
    test "when the note exists" do
      assert Notes.get("simple") == %Note{
               path: "test/support/notes/simple.md",
               slug: "simple",
               title: "Simple"
             }
    end

    test "when the note doesn't exist" do
      refute Notes.get("not_a_note")
    end
  end
end
