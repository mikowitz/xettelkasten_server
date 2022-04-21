defmodule XettelkastenServer.TextHelpersTest do
  use ExUnit.Case, async: true

  import XettelkastenServer, only: [notes_directory: 0]

  alias XettelkastenServer.TextHelpers

  describe "slug_to_path" do
    test "with a simple slug" do
      assert TextHelpers.slug_to_path("basic") ==
               Path.join(
                 notes_directory(),
                 "basic.md"
               )
    end

    test "with a nested_slug" do
      assert TextHelpers.slug_to_path("nested.bird") ==
               Path.join(
                 notes_directory(),
                 "nested/bird.md"
               )
    end
  end

  describe "text_to_path" do
    test "works with any text" do
      assert TextHelpers.text_to_path("A Simple Path") ==
               Path.join(
                 notes_directory(),
                 "a_simple_path.md"
               )
    end

    test "counts forward slashes as nesting" do
      assert TextHelpers.text_to_path("A / Simple /Path") ==
               Path.join(
                 notes_directory(),
                 "a/simple/path.md"
               )
    end
  end
end
