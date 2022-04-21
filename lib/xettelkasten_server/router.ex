defmodule XettelkastenServer.Router do
  use Plug.Router

  alias XettelkastenServer.{Note, Notes, TextHelpers}

  @templates_dir "lib/xettelkasten_server/templates"

  plug(Plug.Logger, log: :debug)

  plug(
    Plug.Static,
    at: "/",
    from: "priv/static",
    gzip: false,
    only: ~w(styles.css)
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn = fetch_query_params(conn)

    tag = conn.params["tag"]

    notes =
      case tag do
        nil -> Notes.all()
        tag when is_bitstring(tag) -> Notes.all(tag: tag)
      end

    render(conn, "notes", notes: notes, tag: tag)
  end

  match "/:slug" do
    case Notes.get(slug) do
      %Note{} = note ->
        rendered_markdown = Note.parse_markdown(note)
        render(conn, "note", rendered_markdown: rendered_markdown, note: note)

      nil ->
        expected_path = TextHelpers.slug_to_path(slug)

        conn
        |> put_status(404)
        |> render("404", expected_path: expected_path)
    end
  end

  defp render(%{status: status} = conn, template, assigns) do
    inner_content = render_template(template, assigns)

    root_assigns =
      [inner_content: inner_content, template: template]
      |> Keyword.put(:note, assigns[:note] || nil)

    body = render_template("root", root_assigns)

    send_resp(conn, status || 200, body)
  end

  def render_template(template, assigns) do
    @templates_dir
    |> Path.join(template)
    |> Kernel.<>(".html.eex")
    |> EEx.eval_file(assigns)
  end
end
