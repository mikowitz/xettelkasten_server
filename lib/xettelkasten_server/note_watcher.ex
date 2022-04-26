defmodule XettelkastenServer.NoteWatcher do
  @moduledoc """
    GenServer that stores the current state for notes to avoid frequent calls to `Notes.all()`.

    It includes a file watcher on the specified notes directory to reload notes as they change.
  """
  use GenServer
  require Logger

  @watcher_name XettelkastenServer.NoteWatcher.Watcher

  alias XettelkastenServer.{Note, TextHelpers}

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    fs_args = [dirs: [XettelkastenServer.notes_directory()], name: @watcher_name]
    {:ok, _} = FileSystem.start_link(fs_args)
    FileSystem.subscribe(@watcher_name)

    {:ok, %{notes: initial_notes_load()}}
  end

  def notes do
    GenServer.call(__MODULE__, :notes)
  end

  def handle_call(:notes, _, %{notes: notes} = state) do
    {:reply, Map.values(notes), state}
  end

  def handle_info({:file_event, _watcher_pid, {path, events}}, %{notes: notes} = state) do
    new_notes =
      cond do
        is_delete?(events) -> delete_note(path, notes)
        is_update?(events) -> update_note(path, notes)
        true -> notes
      end

    {:noreply, %{state | notes: new_notes}}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp delete_note(path, state) do
    Logger.info("deleting note at #{path}")
    Map.delete(state, path)
  end

  defp update_note(path, state) do
    Logger.info("updating note at #{path}")
    Map.put(state, path, XettelkastenServer.Note.from_path(TextHelpers.trim_path(path)))
  end

  defp initial_notes_load do
    XettelkastenServer.notes_directory()
    |> Path.join("**/*.md")
    |> Path.wildcard()
    |> Enum.map(&Note.from_path/1)
    |> Enum.map(fn %{path: path} = note ->
      {
        Path.join(Path.absname(""), path),
        note
      }
    end)
    |> Enum.into(%{})
  end

  defp is_delete?(events) do
    :deleted in events or :removed in events
  end

  defp is_update?(events) do
    :modified in events or :created in events
  end
end
