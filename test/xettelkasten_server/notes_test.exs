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
end
