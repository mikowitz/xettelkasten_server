defmodule XettelkastenServer.Router do
  use Plug.Router

  alias XettelkastenServer.{Note, Notes}

  @templates_dir "lib/xettelkasten_server/templates"

  plug(:match)
  plug(:dispatch)

  get "/" do
    notes = Notes.all()
    render(conn, "notes", notes: notes)
  end

  match "/:slug" do
    case Notes.get(slug) do
      %Note{} = note ->
        rendered_markdown = Note.read(note)
        render(conn, "note", rendered_markdown: rendered_markdown)

      nil ->
        %Note{path: expected_path} = Note.from_slug(slug)

        conn
        |> put_status(404)
        |> render("404", expected_path: expected_path)
    end
  end

  defp render(%{status: status} = conn, template, assigns) do
    body =
      @templates_dir
      |> Path.join(template)
      |> Kernel.<>(".html.eex")
      |> EEx.eval_file(assigns)

    send_resp(conn, status || 200, body)
  end
end
