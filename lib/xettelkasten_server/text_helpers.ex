defmodule XettelkastenServer.TextHelpers do
  import XettelkastenServer, only: [notes_directory: 0]

  def slug_to_path(slug) do
    filepath =
      slug
      |> String.downcase()
      |> String.replace(".", "/")
      |> Kernel.<>(".md")

    Path.join(notes_directory(), filepath)
  end

  def text_to_path(text) do
    filepath =
      text
      |> convert_spaces_to_underscores()
      |> Enum.join("/")
      |> Kernel.<>(".md")

    Path.join(notes_directory(), filepath)
  end

  def text_to_slug(text) do
    text
    |> convert_spaces_to_underscores()
    |> Enum.join(".")
  end

  defp convert_spaces_to_underscores(text) do
    text
    |> String.downcase()
    |> String.split("/")
    |> Enum.map(fn nest ->
      nest
      |> String.trim(" ")
      |> String.replace(" ", "_")
    end)
  end
end
