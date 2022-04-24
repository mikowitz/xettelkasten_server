defmodule XettelkastenServer.Backlink do
  defstruct [:text, :path, :slug, missing: false]

  alias XettelkastenServer.{TextHelpers}

  def from_text(text) do
    path = TextHelpers.text_to_path(text)

    %__MODULE__{
      text: text,
      path: path,
      slug: TextHelpers.text_to_slug(text),
      missing: !File.exists?(path)
    }
  end
end
