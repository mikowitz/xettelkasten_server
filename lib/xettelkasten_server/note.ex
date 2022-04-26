defmodule XettelkastenServer.Note do
  @moduledoc """
    Models a note, encapsulating its content, tags, and backlinks.
  """

  defstruct [:path, :slug, :title, :html, tags: [], backlinks: []]

  alias XettelkastenServer.NoteFileReader

  def from_path(path) do
    case File.read(path) do
      {:ok, _body} ->
        %{yaml: yaml, markdown: markdown} = NoteFileReader.read(path)

        tags_from_yaml = yaml["tags"]
        tags_from_body = extract_tags_from_markdown(markdown)
        title_from_body = extract_title_from_markdown(markdown)

        tags = Enum.sort(tags_from_yaml ++ tags_from_body) |> Enum.uniq()

        title = yaml["title"] || title_from_body || path_to_title(path)

        {:ok, html, backlinks} = extract_backlinks_from_markdown(markdown, title)

        %__MODULE__{
          path: path,
          slug: path_to_slug(path),
          title: title,
          tags: tags,
          html: html,
          backlinks: backlinks
        }

      {:error, _} ->
        nil
    end
  end

  defp extract_tags_from_markdown(text) do
    Regex.scan(~r/#([^#\s]+)/, text)
    |> Enum.map(fn [_, tag] -> tag end)
    |> List.flatten()
  end

  defp extract_title_from_markdown(text) do
    with {:ok, ast, _} <- Earmark.as_ast(text) do
      case ast do
        [{"h1", _, title, _} | _] -> title |> List.flatten() |> List.first()
        _ -> nil
      end
    end
  end

  defp extract_backlinks_from_markdown(markdown, title) do
    with {:ok, ast, backlinks} <- XettelkastenServer.MarkdownParser.parse(markdown, title) do
      {:ok, Earmark.Transform.transform(ast), backlinks}
    end
  end

  def new(path, slug, title) do
    %__MODULE__{
      path: path,
      slug: slug,
      title: title
    }
  end

  defp path_to_slug(path) do
    path
    |> Path.rootname(".md")
    |> String.replace(XettelkastenServer.notes_directory(), "")
    |> String.trim_leading("/")
    |> String.replace("/", ".")
  end

  defp path_to_title(path) do
    path
    |> path_to_slug()
    |> String.split(".")
    |> Enum.map_join(" / ", fn level ->
      level
      |> String.split("_")
      |> Enum.map_join(" ", &String.capitalize/1)
    end)
  end
end
