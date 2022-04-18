defmodule XettelkastenServer.NotesTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.Notes
  alias XettelkastenServer.Note

  test "all" do
    assert Notes.all() == [
             %Note{
               path: "test/support/notes/simple.md",
               slug: "simple",
               title: "Simple"
             }
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
