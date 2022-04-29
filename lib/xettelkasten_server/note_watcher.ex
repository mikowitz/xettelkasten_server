defmodule XettelkastenServer.NoteWatcher do
  @moduledoc """
    GenServer that stores the current state for notes to avoid frequent calls to `Notes.all()`.

    It includes a file watcher on the specified notes directory to reload notes as they change.
  """
  use GenServer
  require Logger

  @watcher_name XettelkastenServer.NoteWatcher.Watcher

  alias XettelkastenServer.Note
  import XettelkastenServer.TextHelpers, only: [trim_path: 1]

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    opts = [dirs: [XettelkastenServer.notes_directory()], name: @watcher_name]

    case FileSystem.start_link(opts) do
      {:ok, _} ->
        FileSystem.subscribe(@watcher_name)

        {:ok, %{notes: initial_notes_load()}}

      error ->
        Logger.warn("Could not start the file system monitor")
        error
    end
  end

  def notes do
    GenServer.call(__MODULE__, :notes)
  end

  def handle_call(:notes, _, %{notes: notes} = state) do
    {:reply, Map.values(notes), state}
  end

  def handle_info({:file_event, _watcher_pid, {path, events}}, %{notes: notes} = state) do
    notes =
      case Path.extname(path) == ".md" do
        true ->
          handle_markdown_file_event(path, events, notes)
          |> update_backlinks(path)

        false ->
          notes
      end

    {:noreply, %{state | notes: notes}}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp handle_markdown_file_event(path, events, notes) do
    cond do
      is_delete?(events) -> delete_note(path, notes)
      is_update?(events) -> update_note(path, notes)
      true -> notes
    end
  end

  defp delete_note(path, notes) do
    Logger.info("deleting note at #{path}")
    Map.delete(notes, path)
  end

  defp update_note(path, notes) do
    Logger.info("updating note at #{path}")
    Map.put(notes, path, Note.from_path(trim_path(path)))
  end

  defp is_delete?(events) do
    :deleted in events or :removed in events
  end

  defp is_update?(events) do
    :modified in events or :created in events
  end

  defp update_backlinks(state, path) do
    linked_path = trim_path(path)

    Enum.map(state, fn {path, note} ->
      backlink_paths = Enum.map(note.backlinks, & &1.path)

      case linked_path in backlink_paths do
        true -> {path, Note.from_path(note.path)}
        false -> {path, note}
      end
    end)
    |> Enum.into(%{})
  end

  if Mix.env() in [:dev, :test] do
    def reload! do
      GenServer.cast(__MODULE__, :reload)
    end

    def handle_cast(:reload, _state) do
      {:noreply, %{notes: initial_notes_load()}}
    end
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
end
