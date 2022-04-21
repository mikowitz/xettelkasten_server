defmodule XettelkastenServer.Notes do
  alias XettelkastenServer.{Note, TextHelpers}

  def all do
    XettelkastenServer.notes_directory()
    |> Path.join("**/*.md")
    |> Path.wildcard()
    |> Enum.map(&Note.from_path/1)
  end

  def all(tag: tag) when is_bitstring(tag) do
    {paths_from_md_tag, _} =
      System.cmd("grep", ["-lr", "-e", "##{tag}\\b", XettelkastenServer.notes_directory()])

    {paths_from_yaml_tag, _} =
      System.cmd("grep", ["-lr", "-e", "- #{tag}\\b", XettelkastenServer.notes_directory()])

    paths = paths_from_md_tag <> "\n" <> paths_from_yaml_tag

    paths
    |> String.split("\n", trim: true)
    |> Enum.map(&Note.from_path/1)
  end

  def get(slug) do
    all()
    |> Enum.find(&(&1.slug == slug))
  end

  def find_note_from_link_text(text) do
    path = TextHelpers.text_to_path(text)

    all()
    |> Enum.find(fn note -> note.path == path end)
  end
end
