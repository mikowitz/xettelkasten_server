defmodule XettelkastenServer.GitWatcher do
  @moduledoc """
      Watches for changes in the notes directory
  """
  use GenServer
  require Logger

  alias XettelkastenServer.GitBehaviour

  import XettelkastenServer, only: [notes_directory: 0]

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    Logger.info("Starting GitWatcher")
    schedule_save()
    {:ok, nil}
  end

  @impl true
  def handle_info(:save, _) do
    case run() do
      {:ok, commit_msg} -> Logger.info("GitWatcher ran successfully with: #{commit_msg}")
      {:error, error} -> Logger.error("GitWatcher errored with: #{error}")
    end

    schedule_save()
    {:noreply, nil}
  end

  defp schedule_save do
    # every ten minutes
    Process.send_after(__MODULE__, :save, 1000 * 60 * 10)
  end

  def changed? do
    case changed_file_count() do
      {:ok, 0} -> false
      {:ok, n} -> n
    end
  end

  defp changed_file_count do
    {n, _} =
      "git status -s -uall #{notes_directory()} | wc -l"
      |> to_charlist()
      |> :os.cmd()
      |> to_string()
      |> String.trim()
      |> Integer.parse()

    {:ok, n}
  end

  def run do
    git = git_impl()

    case changed?() do
      false ->
        {:ok, "No files to commit"}

      changed_count when is_integer(changed_count) ->
        with {:ok, git_data} <- git.add(changed_count),
             {:ok, git_data} <- git.commit(git_data),
             {:ok, git_data} <- git.push(git_data) do
          {:ok, git_data[:commit_message]}
        end
    end
  end

  @behaviour GitBehaviour

  @impl GitBehaviour
  def add(files_changed) do
    case run_git_command(["add", notes_directory()]) do
      {_, 0} -> {:ok, %{files_changed: files_changed}}
      {error, _} -> {:error, error}
    end
  end

  @impl GitBehaviour
  def commit(%{files_changed: files_changed} = git_data) do
    with commit_msg <- build_commit_message(files_changed) do
      case run_git_command(["commit", "-m", ~s["#{commit_msg}"]]) do
        {_, 0} -> {:ok, Map.put(git_data, :commit_message, commit_msg)}
        {error, _} -> {:error, error}
      end
    end
  end

  @impl GitBehaviour
  def push(git_data) do
    case run_git_command(["push", "origin", "HEAD"]) do
      {_, 0} -> {:ok, git_data}
      {error, _} -> {:error, error}
    end
  end

  defp git_impl do
    Application.get_env(:xettelkasten_server, :git_implementation, __MODULE__)
  end

  defp run_git_command(args) do
    System.cmd("git", args)
  end

  defp build_commit_message(files_changed) do
    timestamp = DateTime.utc_now() |> Calendar.strftime("%x %c %Z")

    [
      "Committed",
      files_changed,
      if(files_changed == 1, do: "file", else: "files"),
      "at",
      timestamp
    ]
    |> Enum.join(" ")
  end
end
