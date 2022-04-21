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

  test "'/?tag=' shows a list of notes that share the tag" do
    conn =
      :get
      |> conn("/", %{tag: "tag"})
      |> Router.call(@opts)

    assert conn.status == 200
    {:ok, doc} = Floki.parse_document(conn.resp_body)

    links = Floki.find(doc, "li a")

    assert conn.resp_body =~ ~r"Notes tagged with <span class=\"tag\">#tag</span>"

    assert {"a", [{"href", "/tag"}], ["Tag"]} in links
    refute {"a", [{"href", "/simple"}], ["Simple"]} in links
    refute {"a", [{"href", "/backlinks"}], ["Backlinks"]} in links
  end

  test "'/?tag=' works correctly with a tag in the yaml metadata" do
    conn =
      :get
      |> conn("/", %{tag: "sweet"})
      |> Router.call(@opts)

    assert conn.status == 200
    {:ok, doc} = Floki.parse_document(conn.resp_body)

    links = Floki.find(doc, "li a")

    assert conn.resp_body =~ ~r"Notes tagged with <span class=\"tag\">#sweet</span>"

    assert length(links) == 1
    assert {"a", [{"href", "/with_header"}], ["My Cool Note"]} in links
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
      assert index_link == [{"a", [{"href", "/"}], ["← Index"]}]
    end

    test "renders a tag as a link" do
      conn =
        :get
        |> conn("/tag", "")
        |> Router.call(@opts)

      assert conn.status == 200
      {:ok, doc} = Floki.parse_document(conn.resp_body)

      tag_links = Floki.find(doc, "a.tag")
      assert {"a", [{"href", "/?tag=tag"}, {"class", "tag"}], ["#tag"]} in tag_links
    end

    test "renders a list of tags on the page in the side nav" do
      conn =
        :get
        |> conn("/with_header")
        |> Router.call(@opts)

      assert conn.status == 200
      {:ok, doc} = Floki.parse_document(conn.resp_body)

      sidebar_tag_links = Floki.find(doc, "nav .nav-tags ul li.tag")

      assert length(sidebar_tag_links) == 5
    end

    test "renders the content of the linked file" do
      conn =
        :get
        |> conn("/simple", "")
        |> Router.call(@opts)

      {:ok, doc} = Floki.parse_document(conn.resp_body)

      [{"h1", _, [header]}] = Floki.find(doc, "h1")
      [{"p", _, [paragraph_text]} | _] = Floki.find(doc, "p")

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
      assert {"a", [{"href", "/nested.text_block"}], ["nested/text block"]} in backlinks
    end

    test "renders a nested note" do
      conn =
        :get
        |> conn("/nested.bird", "")
        |> Router.call(@opts)

      assert conn.status == 200

      {:ok, doc} = Floki.parse_document(conn.resp_body)

      [{"h1", _, [header]}] = Floki.find(doc, "h1")
      [{"p", _, [text]}] = Floki.find(doc, "p")

      assert String.trim(header) == "I'm a bird"
      assert String.trim(text) == "Just a pretty little tweety bird"
    end
  end

  describe "/:slug with an invalid slug" do
    test "renders a 404 page if the unnested slug doesn't map to a existing file" do
      conn =
        :get
        |> conn("/not_a_page", "")
        |> Router.call(@opts)

      assert conn.status == 404

      assert conn.resp_body =~
               ~r"Could not find a markdown file at test/support/notes/not_a_page.md"
    end

    test "renders a 404 page if the nested slug doesn't map to a existing file" do
      conn =
        :get
        |> conn("/really.not.a_page", "")
        |> Router.call(@opts)

      assert conn.status == 404

      assert conn.resp_body =~
               ~r"Could not find a markdown file at test/support/notes/really/not/a_page.md"
    end
  end
end
