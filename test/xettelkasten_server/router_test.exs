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
    assert conn.resp_body =~ ~r"<a href=./.>Index</a>"

    assert conn.resp_body =~ ~r"<a href=./simple.>Simple</a>"
  end

  describe "'/:slug'" do
    test "renders a link to the index" do
      conn =
        :get
        |> conn("/simple", "")
        |> Router.call(@opts)

      assert conn.status == 200
      assert conn.resp_body =~ ~r"<a href=./.>Index</a>"
    end

    test "renders the content of the linked file" do
      conn =
        :get
        |> conn("/simple", "")
        |> Router.call(@opts)

      assert conn.resp_body =~ ~r"<h1>\nA simple note</h1>"
      assert conn.resp_body =~ ~r"<p>\nHello there!</p>"
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
