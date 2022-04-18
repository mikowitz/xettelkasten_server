defmodule XettelkastenServer.Note do
  defstruct [:path, :slug, :title]

  def from_path(path) do
    slug = path_to_slug(path)
    title = path_to_title(path)

    %__MODULE__{
      path: path,
      slug: slug,
      title: title
    }
  end

  defp path_to_slug(path) do
    path
    |> Path.rootname(".md")
    |> String.replace(XettelkastenServer.notes_directory(), "")
    |> String.trim_leading("/")
  end

  defp path_to_title(path) do
    path
    |> path_to_slug()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
