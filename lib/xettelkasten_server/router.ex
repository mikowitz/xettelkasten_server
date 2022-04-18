defmodule XettelkastenServer.Router do
  use Plug.Router

  alias XettelkastenServer.{Note, Notes}

  plug(:match)
  plug(:dispatch)

  get "/" do
    notes = Notes.all()
    page = EEx.eval_file("lib/xettelkasten_server/templates/notes.html.eex", notes: notes)
    send_resp(conn, 200, page)
  end

  match "/:slug" do
    case Notes.get(slug) do
      %Note{path: path} ->
        {:ok, f} = File.read(path)
        {:ok, rendered_markdown, _} = Earmark.as_html(f)

        page =
          EEx.eval_file("lib/xettelkasten_server/templates/note.html.eex",
            rendered_markdown: rendered_markdown
          )

        send_resp(conn, 200, page)

      nil ->
        path = Path.join(XettelkastenServer.notes_directory(), slug <> ".md")

        page =
          EEx.eval_file("lib/xettelkasten_server/templates/404.html.eex", expected_path: path)

        send_resp(conn, 404, page)
    end
  end
end
