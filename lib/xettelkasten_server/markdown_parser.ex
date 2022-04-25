defmodule XettelkastenServer.MarkdownParser do
  @moduledoc """
    Custom XettelkastenServer functions for parsing markdown as an Earmark AST tree
  """

  alias XettelkastenServer.Backlink

  @backlink_regex ~r/\[\[[^]]+\]\]/
  @tag_regex ~r/\#[\S]+/

  def parse(markdown, title \\ nil) when is_bitstring(markdown) do
    {:ok, ast, _} = Earmark.as_ast(markdown)

    {:ok, backlink_agent} = Agent.start_link(fn -> [] end)

    ast =
      Earmark.Transform.map_ast(ast, fn node ->
        node
        |> detect_backlinks(backlink_agent)
        |> detect_tags()
      end)
      |> ensure_h1_tag(title)

    backlinks = Agent.get(backlink_agent, & &1) |> Enum.reverse()

    Agent.stop(backlink_agent)

    {:ok, ast, backlinks}
  end

  defp detect_backlinks(node, agent) when is_bitstring(node) do
    res = parse_backlinks(node, agent)

    case length(res) do
      1 -> List.first(res)
      _ -> List.flatten(res)
    end
  end

  defp detect_backlinks(node, _), do: node

  defp parse_backlinks(str, agent) do
    Regex.split(@backlink_regex, str, include_captures: true, trim: true)
    |> Enum.map(&parse_backlink(&1, agent))
  end

  defp parse_backlink("[[" <> str, agent) do
    title = String.trim_trailing(str, "]")
    backlink = Backlink.from_text(title)

    Agent.update(agent, &[backlink | &1])

    classes =
      ["backlink", if(backlink.missing, do: "missing")]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    {
      "span",
      [{"class", classes}],
      [
        "[[",
        {"a", [{"href", "/#{backlink.slug}"}], [backlink.text], %{}},
        "]]"
      ],
      %{}
    }
  end

  defp parse_backlink(str, _), do: str

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

  defp ensure_h1_tag(ast, nil), do: ast

  defp ensure_h1_tag(ast, title) do
    case ast do
      [{"h1", _, _, _} | _] ->
        ast

      _ ->
        [{"h1", [], [[title]], %{}} | ast]
    end
  end
end
