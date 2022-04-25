defmodule XettelkastenServer.NoteFileReader do
  @moduledoc """
    Responsible for reading note markdown files and separating out and parsing an optional YAML header.
  """

  @empty_yaml %{"tags" => [], "title" => nil}

  def read(path) do
    case File.read(path) do
      {:ok, file} ->
        {yaml, markdown} = split_yaml_and_markdown(file)
        %{yaml: yaml, markdown: markdown}

      {:error, _} = error ->
        error
    end
  end

  defp split_yaml_and_markdown(file) do
    case String.split(file, "---\n", trim: true, parts: 2) do
      [markdown] ->
        {@empty_yaml, markdown}

      [yaml, markdown] ->
        {:ok, yaml} = YamlElixir.read_from_string(yaml)
        {Map.merge(@empty_yaml, yaml), markdown}
    end
  end
end
