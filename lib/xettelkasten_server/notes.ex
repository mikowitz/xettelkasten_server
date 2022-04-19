defmodule XettelkastenServer.Notes do
  alias XettelkastenServer.Note

  def all do
    XettelkastenServer.notes_directory()
    |> Path.join("**/*.md")
    |> Path.wildcard()
    |> Enum.map(&Note.from_path/1)
  end

  def all(tag: tag) when is_bitstring(tag) do
    {paths, 0} =
      System.cmd("grep", ["-lr", "-e", "##{tag}\\b", XettelkastenServer.notes_directory()])

    paths
    |> String.split("\n", trim: true)
    |> Enum.map(&Note.from_path/1)
  end

  def get(slug) do
    all()
    |> Enum.find(&(&1.slug == slug))
  end
end
