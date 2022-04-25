defmodule XettelkastenServer.BacklinkTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.Backlink

  describe "from_text" do
    test "works with a simple case matching filename" do
      backlink = Backlink.from_text("Simple")

      assert backlink.text == "Simple"
      assert backlink.path == Path.join(XettelkastenServer.notes_directory(), "simple.md")
      assert backlink.slug == "simple"
      refute backlink.missing
    end

    test "works with a nested filename" do
      backlink = Backlink.from_text("Nested / Bird")

      assert backlink.text == "Nested / Bird"
      assert backlink.path == Path.join(XettelkastenServer.notes_directory(), "nested/bird.md")
      assert backlink.slug == "nested.bird"
      refute backlink.missing
    end

    test "works with a missing filename" do
      backlink = Backlink.from_text("Not A Note")

      assert backlink.text == "Not A Note"
      assert backlink.path == Path.join(XettelkastenServer.notes_directory(), "not_a_note.md")
      assert backlink.slug == "not_a_note"
      assert backlink.missing
    end

    test "works with a backlink specifying path and title" do
      backlink = Backlink.from_text("simple|A Simple Note")

      assert backlink.text == "A Simple Note"
      assert backlink.path == Path.join(XettelkastenServer.notes_directory(), "simple.md")
      assert backlink.slug == "simple"
      refute backlink.missing

    end
  end
end
