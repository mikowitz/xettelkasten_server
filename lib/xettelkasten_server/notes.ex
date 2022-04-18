defmodule XettelkastenServer.Notes do
  alias XettelkastenServer.Note

  def all do
    XettelkastenServer.notes_directory()
    |> Path.join("*.md")
    |> Path.wildcard()
    |> Enum.map(&Note.from_path/1)
  end

  def get(slug) do
    all()
    |> Enum.find(& &1.slug == slug)
  end
end
