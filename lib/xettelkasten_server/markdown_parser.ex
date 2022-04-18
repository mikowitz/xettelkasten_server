defmodule XettelkastenServer.MarkdownParser do
  alias XettelkastenServer.Note

  @backlink_regex ~r/\[\[[^]]+\]\]/

  def parse(markdown) when is_bitstring(markdown) do
    {:ok, ast, _} = Earmark.as_ast(markdown)

    ast =
      Earmark.Transform.map_ast(ast, fn node ->
        detect_backlinks(node)
      end)

    {:ok, ast}
  end

  defp detect_backlinks(node) when is_bitstring(node) do
    parse_backlinks(node)
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
end
