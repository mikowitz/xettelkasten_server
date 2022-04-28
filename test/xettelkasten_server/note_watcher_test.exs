defmodule XettelkastenServer.NoteWatcherTest do
  use ExUnit.Case

  @delay Application.compile_env(:xettelkasten_server, :file_watcher_delay_ms)

  alias XettelkastenServer.{Backlink, Note, Notes}

  setup do
    on_exit(fn ->
      File.rm("test/support/notes/my_test_note.md")
      File.rm("test/support/notes/linking_note.md")
      File.rm("test/support/notes/linked_note.md")
    end)
  end

  test "updates the state" do
    base_path =
      Path.join(
        XettelkastenServer.notes_directory(),
        "my_test_note.md"
      )

    path = Path.absname(base_path)

    refute Notes.get("my_test_note")

    :ok = File.write!(path, "# hello!", [:write])

    :timer.sleep(@delay)

    %Note{tags: tags} = Notes.get("my_test_note")

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

    %Note{tags: tags} = Notes.get("my_test_note")

    assert tags == ~w(bar foo)

    :timer.sleep(@delay)

    :ok = File.rm(path)

    :timer.sleep(@delay)

    refute Notes.get("my_test_note")
  end

  test "updates backlinks to a note when the note changes" do
    base_path =
      Path.join(
        XettelkastenServer.notes_directory(),
        "linking_note.md"
      )

    path = Path.absname(base_path)

    :ok = File.write!(path, "# hello!\n\n[[linked note]]", [:write])

    :timer.sleep(@delay)

    %Note{backlinks: backlinks} = Notes.get("linking_note")

    assert %Backlink{
             text: "linked note",
             path: "test/support/notes/linked_note.md",
             slug: "linked_note",
             missing: true
           } in backlinks

    linked_path =
      Path.join(
        XettelkastenServer.notes_directory(),
        "linked_note.md"
      )
      |> Path.absname()

    :ok = File.write!(linked_path, "I exist!", [:write])

    :timer.sleep(@delay)

    %Note{backlinks: backlinks} = Notes.get("linking_note")

    assert %Backlink{
             text: "linked note",
             path: "test/support/notes/linked_note.md",
             slug: "linked_note",
             missing: false
           } in backlinks
  end
end
