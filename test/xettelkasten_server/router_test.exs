defmodule XettelkastenServer.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias XettelkastenServer.Router

  @opts Router.init([])

  test "'/' shows a list of existing notes" do
    conn =
      :get
      |> conn("/", "")
      |> Router.call(@opts)

    assert conn.status == 200
    {:ok, doc} = Floki.parse_document(conn.resp_body)

    links = Floki.find(doc, "a")

    assert {"a", [{"href", "/"}], ["Index"]} in links
    assert {"a", [{"href", "/simple"}], ["Simple"]} in links
    assert {"a", [{"href", "/backlinks"}], ["Backlinks"]} in links
  end

  describe "'/:slug'" do
    test "renders a link to the index" do
      conn =
        :get
        |> conn("/simple", "")
        |> Router.call(@opts)

      assert conn.status == 200
      {:ok, doc} = Floki.parse_document(conn.resp_body)

      index_link = Floki.find(doc, "a")
      assert index_link == [{"a", [{"href", "/"}], ["Index"]}]
    end

    test "renders the content of the linked file" do
      conn =
        :get
        |> conn("/simple", "")
        |> Router.call(@opts)

      {:ok, doc} = Floki.parse_document(conn.resp_body)

      [{"h1", _, [header]}] = Floki.find(doc, "h1")
      [{"p", _, [paragraph_text]}] = Floki.find(doc, "p")

      assert String.trim(header) == "A simple note"
      assert String.trim(paragraph_text) == "Hello there!"
    end

    test "renders backlinks as links with the correct slugs" do
      conn =
        :get
        |> conn("/backlinks", "")
        |> Router.call(@opts)

      {:ok, doc} = Floki.parse_document(conn.resp_body)

      backlinks = Floki.find(doc, "span.backlink a")

      assert length(backlinks) == 4

      assert {"a", [{"href", "/toplevel"}], ["toplevel"]} in backlinks
      assert {"a", [{"href", "/nested"}], ["nested"]} in backlinks
      assert {"a", [{"href", "/first"}], ["first"]} in backlinks
      assert {"a", [{"href", "/text_block"}], ["text block"]} in backlinks
    end

    test "renders a 404 page if the slug doesn't map to a existing file" do
      conn =
        :get
        |> conn("/not_a_page", "")
        |> Router.call(@opts)

      assert conn.status == 404

      assert conn.resp_body =~
               ~r"Could not find a markdown file at test/support/notes/not_a_page.md"
    end
  end
end
