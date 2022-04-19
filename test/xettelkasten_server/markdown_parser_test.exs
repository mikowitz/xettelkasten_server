defmodule XettelkastenServer.MarkdownParserTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.MarkdownParser

  describe "backlinks" do
    test "parse correctly handles a simple backlink" do
      {:ok, ast} = MarkdownParser.parse("[[hello]]")

      assert ast ==
               [
                 {"p", [],
                  [
                    {"span", [{"class", "backlink"}],
                     [
                       "[[",
                       {"a", [{"href", "/hello"}], ["hello"], %{}},
                       "]]"
                     ], %{}}
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
                       {"span", [{"class", "backlink"}],
                        [
                          "[[",
                          {"a", [{"href", "/hello"}], ["hello"], %{}},
                          "]]"
                        ], %{}}
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

  describe "tags" do
    test "single tag" do
      {:ok, ast} = MarkdownParser.parse("#tag")

      assert ast ==
               [
                 {"p", [],
                  [
                    [{"a", [{"href", "/?tag=tag"}, {"class", "tag"}], ["#tag"], %{}}]
                  ], %{}}
               ]
    end

    test "multiple tags" do
      {:ok, ast} = MarkdownParser.parse("#tag #second_tag")

      assert ast ==
               [
                 {"p", [],
                  [
                    [
                      {"a", [{"href", "/?tag=tag"}, {"class", "tag"}], ["#tag"], %{}},
                      " ",
                      {"a", [{"href", "/?tag=second_tag"}, {"class", "tag"}], ["#second_tag"],
                       %{}}
                    ]
                  ], %{}}
               ]
    end

    test "non-initial tag" do
      {:ok, ast} = MarkdownParser.parse("this tag is a #tag tag")

      assert ast ==
               [
                 {"p", [],
                  [
                    [
                      "this tag is a ",
                      {"a", [{"href", "/?tag=tag"}, {"class", "tag"}], ["#tag"], %{}},
                      " tag"
                    ]
                  ], %{}}
               ]
    end
  end
end
