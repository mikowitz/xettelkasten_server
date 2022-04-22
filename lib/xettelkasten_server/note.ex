defmodule XettelkastenServer.Note do
  defstruct [:path, :slug, :title, :markdown, tags: []]

  alias XettelkastenServer.NoteFileReader

  def from_path(path) do
    case File.read(path) do
      {:ok, _body} ->
        %{yaml: yaml, markdown: markdown} = NoteFileReader.read(path)

        tags_from_yaml = Enum.map(yaml["tags"], &"##{&1}")
        tags_from_body = extract_tags_from_markdown(markdown)

        tags = Enum.sort(tags_from_yaml ++ tags_from_body) |> Enum.uniq()

        %__MODULE__{
          path: path,
          slug: path_to_slug(path),
          title: yaml["title"] || path_to_title(path),
          tags: tags,
          markdown: markdown
        }

      {:error, _} ->
        nil
    end
  end

  defp extract_tags_from_markdown(text) do
    Regex.scan(~r/#[^#\s]+/, text)
    |> List.flatten()
  end

  def new(path, slug, title) do
    %__MODULE__{
      path: path,
      slug: slug,
      title: title
    }
  end

  def parse_markdown(%__MODULE__{markdown: markdown, title: title}) do
    with {:ok, ast} <- XettelkastenServer.MarkdownParser.parse(markdown, title) do
      Earmark.Transform.transform(ast)
    end
  end

  def parse_markdown(nil), do: {:error, :enoent}

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
    |> Enum.map(fn level ->
      level
      |> String.split("_")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join(" ")
    end)
    |> Enum.join("/")
  end
end
