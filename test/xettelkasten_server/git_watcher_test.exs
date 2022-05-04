defmodule XettelkastenServer.GitWatcherTest do
  use ExUnit.Case

  import Mox

  alias XettelkastenServer.GitWatcher

  describe "with no changed files" do
    test "changed? returns false" do
      refute GitWatcher.changed?()
    end

    test "run" do
      assert {:ok, "No files to commit"} = GitWatcher.run()
    end
  end

  describe "with a file changed in the notes directory" do
    setup do
      path = Path.join(XettelkastenServer.notes_directory(), "my_test_note.md")
      write_file_at!(path)

      on_exit(fn ->
        File.rm(path)
      end)
    end

    test "changed? returns true" do
      assert GitWatcher.changed?()
    end

    test "run" do
      expect(GitBehaviourMock, :add, fn _ -> {:ok, %{files_changed: 1}} end)

      expect(GitBehaviourMock, :commit, fn data ->
        {:ok, Map.put(data, :commit_message, "Committed 1 file at TIME")}
      end)

      expect(GitBehaviourMock, :push, fn data -> {:ok, data} end)
      assert {:ok, "Committed 1 file at TIME"} = GitWatcher.run()
    end
  end

  describe "with a file outside the notes directory changed" do
    setup do
      path = "my_test_note.md"
      write_file_at!(path)

      on_exit(fn ->
        File.rm(path)
      end)
    end

    test "changed? returns false" do
      refute GitWatcher.changed?()
    end

    test "run" do
      assert {:ok, "No files to commit"} = GitWatcher.run()
    end
  end

  describe "when git errors" do
    setup do
      path = Path.join(XettelkastenServer.notes_directory(), "my_test_note.md")
      write_file_at!(path)

      on_exit(fn ->
        File.rm(path)
      end)
    end

    test "when adding fails" do
      expect(GitBehaviourMock, :add, fn _ -> {:error, "Error running `git add`"} end)

      expect(GitBehaviourMock, :commit, fn data ->
        {:ok, Map.put(data, :commit_message, "Committed 1 file at TIME")}
      end)

      expect(GitBehaviourMock, :push, fn data -> {:ok, data} end)
      assert {:error, "Error running `git add`"} = GitWatcher.run()
    end

    test "when committing fails" do
      expect(GitBehaviourMock, :add, fn _ -> {:ok, %{files_changed: 1}} end)

      expect(GitBehaviourMock, :commit, fn _ ->
        {:error, "Error running `git commit -m \"Committed 1 file at TIME\"`"}
      end)

      expect(GitBehaviourMock, :push, fn data -> {:ok, data} end)

      assert {:error, "Error running `git commit -m \"Committed 1 file at TIME\"`"} =
               GitWatcher.run()
    end

    test "when pushing fails" do
      expect(GitBehaviourMock, :add, fn _ -> {:ok, %{files_changed: 1}} end)

      expect(GitBehaviourMock, :commit, fn data ->
        {:ok, Map.put(data, :commit_message, "Committed 1 file at TIME")}
      end)

      expect(GitBehaviourMock, :push, fn _ -> {:error, "Failed to push to origin"} end)
      assert {:error, "Failed to push to origin"} = GitWatcher.run()
    end
  end

  defp write_file_at!(path) do
    path
    |> Path.absname()
    |> File.write!("Hello")
  end
end
