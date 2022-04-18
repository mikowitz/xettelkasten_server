defmodule XettelkastenServer.MarkdownParserTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.MarkdownParser

  test "parse correctly handles a simple backlink" do
    {:ok, ast} = MarkdownParser.parse("[[hello]]")

    assert ast ==
             [
               {"p", [],
                [
                  [
                    {"span", [{"class", "backlink"}],
                     [
                       "[[",
                       {"a", [{"href", "/hello"}], ["hello"], %{}},
                       "]]"
                     ], %{}}
                  ]
                ], %{}}
             ]
  end

  test "parse correctly handles a nested backlink" do
    {:ok, ast} = MarkdownParser.parse("- [[hello]]")

    assert ast ==
             [
               {"ul", [],
                [
                  {"li", [],
                   [
                     [
                       {"span", [{"class", "backlink"}],
                        [
                          "[[",
                          {"a", [{"href", "/hello"}], ["hello"], %{}},
                          "]]"
                        ], %{}}
                     ]
                   ], %{}}
                ], %{}}
             ]
  end

  test "parse correctly handles multiple backlinks in one line" do
    {:ok, ast} = MarkdownParser.parse("this is [[one backlink]] and [[Another]]")

    assert ast ==
             [
               {"p", [],
                [
                  [
                    "this is ",
                    {"span", [{"class", "backlink"}],
                     [
                       "[[",
                       {"a", [{"href", "/one_backlink"}], ["one backlink"], %{}},
                       "]]"
                     ], %{}},
                    " and ",
                    {"span", [{"class", "backlink"}],
                     [
                       "[[",
                       {"a", [{"href", "/another"}], ["Another"], %{}},
                       "]]"
                     ], %{}}
                  ]
                ], %{}}
             ]
  end
end
