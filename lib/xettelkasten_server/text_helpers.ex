defmodule XettelkastenServer.TextHelpers do
  @moduledoc """
      Common helper functions for converting between file paths, URL slugs, and titles
  """

  import XettelkastenServer, only: [notes_directory: 0]

  def titleize(s) do
    s
    |> String.split("/", trim: true)
    |> Enum.map_join(" /", fn nest ->
      nest
      |> String.split(" ", trim: true)
      |> Enum.map_join(" ", &String.capitalize/1)
    end)
  end

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

  def path_to_text(path) do
    path
    |> Path.rootname()
    |> String.split("/")
    |> Enum.map_join(" / ", fn nest ->
      nest
      |> String.split("_")
      |> Enum.map_join(" ", &String.capitalize/1)
    end)
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
