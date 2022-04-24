defmodule XettelkastenServer.Router do
  use Plug.Router

  alias XettelkastenServer.{Backlink, Note, Notes, TextHelpers}

  @templates_dir "priv/static/templates"

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
        incoming_backlinks =
          Notes.with_backlinks_to(note.slug)
          |> Enum.map(fn note ->
            note.path
            |> String.replace(XettelkastenServer.notes_directory(), "")
            |> String.trim_leading("/")
            |> TextHelpers.path_to_text()
            |> Backlink.from_text()
          end)

        render(conn, "note",
          rendered_markdown: note.html,
          incoming_backlinks: incoming_backlinks,
          note: note
        )

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
      |> Keyword.put(:incoming_backlinks, assigns[:incoming_backlinks] || [])

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
