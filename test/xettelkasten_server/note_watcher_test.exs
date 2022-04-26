defmodule XettelkastenServer.NoteWatcherTest do
  use ExUnit.Case

  @delay Application.compile_env(:xettelkasten_server, :file_watcher_delay_ms)

  setup do
    on_exit(fn -> File.rm("test/support/notes/my_test_note.md") end)
  end

  test "updates the state" do
    base_path =
      Path.join(
        XettelkastenServer.notes_directory(),
        "my_test_note.md"
      )

    path =
      Path.join(
        Path.absname(""),
        base_path
      )

    refute XettelkastenServer.Notes.get("my_test_note")

    :ok = File.write!(path, "# hello!", [:write])

    :timer.sleep(@delay)

    %XettelkastenServer.Note{tags: tags} = XettelkastenServer.Notes.get("my_test_note")

    assert tags == []

    :timer.sleep(@delay)

    File.write!(path, """
    ---
    tags:
    - foo
    - bar
    ---
    hello
    """)

    :timer.sleep(@delay)

    %XettelkastenServer.Note{tags: tags} = XettelkastenServer.Notes.get("my_test_note")

    assert tags == ~w(bar foo)

    :timer.sleep(@delay)

    :ok = File.rm(path)

    :timer.sleep(@delay)

    refute XettelkastenServer.Notes.get("my_test_note")
  end

  def my_test_note_path do
  end
end
