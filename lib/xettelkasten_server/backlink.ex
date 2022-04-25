defmodule XettelkastenServer.Backlink do
  @moduledoc """
    Models a backlink from one note to another.
  """

  defstruct [:text, :path, :slug, missing: false]

  alias XettelkastenServer.TextHelpers

  def from_text(text) do
    {path, title} =
      case String.split(text, "|", trim: true) do
        [path] ->
          path = String.trim(path)
          {path, path}

        [path, title] ->
          {String.trim(path), String.trim(title)}
      end

    slug = TextHelpers.text_to_slug(path)
    path = TextHelpers.text_to_path(path)

    %__MODULE__{
      text: title,
      path: path,
      slug: slug,
      missing: !File.exists?(path)
    }
  end
end
