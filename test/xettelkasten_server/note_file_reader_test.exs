defmodule XettelkastenServer.NoteFileReaderTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.NoteFileReader

  test "parses the file into yaml header and markdown body" do
    path = note_path("with_header")

    file_contents = NoteFileReader.read(path)

    assert file_contents.yaml == %{
             "title" => "My Cool Note",
             "tags" => ~w(awesome sweet prettycool)
           }

    assert is_bitstring(file_contents.markdown)
  end

  test "returns an empty yaml header when it is not present" do
    path = note_path("simple")

    file_contents = NoteFileReader.read(path)

    assert file_contents.yaml == %{"tags" => [], "title" => nil}
    assert is_bitstring(file_contents.markdown)
  end

  test "returns an empty yaml header when the divider is present but no yaml is included" do
    path = note_path("nested/bird")

    file_contents = NoteFileReader.read(path)

    assert file_contents.yaml == %{"tags" => [], "title" => nil}
    assert is_bitstring(file_contents.markdown)
  end

  test "returns posix error if file cannot be read" do
    path = note_path("not_a_note")

    assert NoteFileReader.read(path) == {:error, :enoent}
  end

  def note_path(filename) do
    Path.join(XettelkastenServer.notes_directory(), filename <> ".md")
  end
end
