defmodule XettelkastenServer.MarkdownParser do
  alias XettelkastenServer.Note

  @backlink_regex ~r/\[\[[^]]+\]\]/
  @tag_regex ~r/\#[\S]+/

  def parse(markdown) when is_bitstring(markdown) do
    {:ok, ast, _} = Earmark.as_ast(markdown)

    ast =
      Earmark.Transform.map_ast(ast, fn node ->
        node
        |> detect_backlinks()
        |> detect_tags()
      end)

    {:ok, ast}
  end

  defp detect_backlinks(node) when is_bitstring(node) do
    res = parse_backlinks(node)

    case length(res) do
      1 -> List.first(res)
      _ -> List.flatten(res)
    end
  end

  defp detect_backlinks(node), do: node

  defp parse_backlinks(str) do
    Regex.split(@backlink_regex, str, include_captures: true, trim: true)
    |> Enum.map(&parse_backlink/1)
  end

  defp parse_backlink("[[" <> str) do
    title = String.trim_trailing(str, "]")
    note = Note.from_title(title)

    {
      "span",
      [{"class", "backlink"}],
      [
        "[[",
        {"a", [{"href", "/#{note.slug}"}], [note.title], %{}},
        "]]"
      ],
      %{}
    }
  end

  defp parse_backlink(str), do: str

  defp detect_tags(node) when is_bitstring(node) do
    parse_tags(node)
  end

  defp detect_tags(node), do: node

  defp parse_tags(str) do
    Regex.split(@tag_regex, str, include_captures: true, trim: true)
    |> Enum.map(&parse_tag/1)
  end

  defp parse_tag("#" <> tag = label) do
    {
      "a",
      [{"href", "/?tag=#{tag}"}, {"class", "tag"}],
      [label],
      %{}
    }
  end

  defp parse_tag(str), do: str
end
