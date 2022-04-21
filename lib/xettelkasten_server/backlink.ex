defmodule XettelkastenServer.Backlink do
  defstruct [:text, :path, :slug, missing: false]

  alias XettelkastenServer.{Note, Notes, TextHelpers}

  def from_text(text) do
    {slug, path, missing} =
      case Notes.find_note_from_link_text(text) do
        %Note{slug: slug, path: path} ->
          {slug, path, false}

        nil ->
          slug = TextHelpers.text_to_slug(text)
          path = TextHelpers.slug_to_path(slug)
          {slug, path, true}
      end

    %__MODULE__{
      text: text,
      path: path,
      slug: slug,
      missing: missing
    }
  end
end
