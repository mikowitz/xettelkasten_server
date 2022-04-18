defmodule XettelkastenServer.Note do
  defstruct [:path, :slug, :title]

  def from_path(path) do
    slug = path_to_slug(path)
    title = path_to_title(path)
    new(path, slug, title)
  end

  def from_slug(slug) do
    path = slug_to_path(slug)
    title = path_to_title(path)
    new(path, slug, title)
  end

  def new(path, slug, title) do
    %__MODULE__{
      path: path,
      slug: slug,
      title: title
    }
  end

  def read(%__MODULE__{path: path}) do
    with {:ok, markdown} <- File.read(path) do
      {:ok, html, _} = Earmark.as_html(markdown)
      html
    end
  end

  defp path_to_slug(path) do
    path
    |> Path.rootname(".md")
    |> String.replace(XettelkastenServer.notes_directory(), "")
    |> String.trim_leading("/")
  end

  defp slug_to_path(slug) do
    Path.join(
      XettelkastenServer.notes_directory(),
      slug <> ".md"
    )
  end

  defp path_to_title(path) do
    path
    |> path_to_slug()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
