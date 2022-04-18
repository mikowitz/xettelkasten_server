defmodule XettelkastenServer.NotesTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.Notes
  alias XettelkastenServer.Note

  test "all" do
    assert Notes.all() == [
             Note.from_slug("backlinks"),
             Note.from_slug("nested.bird"),
             Note.from_slug("simple"),
             Note.from_slug("simple_backlink")
           ]
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
