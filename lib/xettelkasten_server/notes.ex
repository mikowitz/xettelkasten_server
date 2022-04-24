defmodule XettelkastenServer.Notes do
  alias XettelkastenServer.Note

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

  def with_backlinks_to(slug) do
    all()
    |> Enum.filter(fn %{backlinks: backlinks} ->
      slug in Enum.map(backlinks, & &1.slug)
    end)
  end
end
