defmodule XettelkastenServer.MarkdownParserTest do
  use ExUnit.Case, async: true

  alias XettelkastenServer.MarkdownParser

  describe "backlinks" do
    test "parse correctly handles a simple backlink" do
      {:ok, ast, _} = MarkdownParser.parse("[[simple]]")

      assert ast ==
               [
                 {"p", [],
                  [
                    {"span", [{"class", "backlink"}],
                     [
                       "[[",
                       {"a", [{"href", "/simple"}], ["simple"], %{}},
                       "]]"
                     ], %{}}
                  ], %{}}
               ]
    end

    test "parse correctly handles a nested backlink" do
      {:ok, ast, _} = MarkdownParser.parse("- [[simple]]")

      assert ast ==
               [
                 {"ul", [],
                  [
                    {"li", [],
                     [
                       {"span", [{"class", "backlink"}],
                        [
                          "[[",
                          {"a", [{"href", "/simple"}], ["simple"], %{}},
                          "]]"
                        ], %{}}
                     ], %{}}
                  ], %{}}
               ]
    end

    test "parse correctly handles a backlink with a missing file" do
      {:ok, ast, _} = MarkdownParser.parse("[[no good]]")

      assert ast ==
               [
                 {"p", [],
                  [
                    {"span", [{"class", "backlink missing"}],
                     [
                       "[[",
                       {"a", [{"href", "/no_good"}], ["no good"], %{}},
                       "]]"
                     ], %{}}
                  ], %{}}
               ]
    end

    test "parse correctly handles multiple backlinks in one line" do
      {:ok, ast, _} = MarkdownParser.parse("this is one [[backlinks]] and [[Another]]")

      assert ast ==
               [
                 {"p", [],
                  [
                    [
                      "this is one ",
                      {"span", [{"class", "backlink"}],
                       [
                         "[[",
                         {"a", [{"href", "/backlinks"}], ["backlinks"], %{}},
                         "]]"
                       ], %{}},
                      " and ",
                      {"span", [{"class", "backlink missing"}],
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
      {:ok, ast, _} = MarkdownParser.parse("#tag")

      assert ast ==
               [
                 {"p", [],
                  [
                    [{"a", [{"href", "/?tag=tag"}, {"class", "tag"}], ["#tag"], %{}}]
                  ], %{}}
               ]
    end

    test "multiple tags" do
      {:ok, ast, _} = MarkdownParser.parse("#tag #second_tag")

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
      {:ok, ast, _} = MarkdownParser.parse("this tag is a #tag tag")

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

  describe "ensure_h1_tag" do
    test "leaves an existing h1 tag unchanged" do
      {:ok, ast, _} = MarkdownParser.parse("# Hello", "Better title")

      assert ast == [
               {"h1", [], [["Hello"]], %{}}
             ]
    end

    test "inserts a header from metadata if no h1 tag is present" do
      {:ok, ast, _} = MarkdownParser.parse("hello", "Better title")

      assert ast == [
               {"h1", [], [["Better title"]], %{}},
               {"p", [], [["hello"]], %{}}
             ]
    end
  end
end
