defmodule XettelkastenServer.Notes do
  @moduledoc """
    Query methods for notes
  """

  alias XettelkastenServer.NoteWatcher

  def all do
    NoteWatcher.notes()
  end

  def all(tag: tag) when is_bitstring(tag) do
    all()
    |> Enum.filter(&(tag in &1.tags))
  end

  def get(slug) do
    all()
    |> Enum.find(&(&1.slug == slug))
  end

  def with_backlinks_to(slug) do
    all()
    |> Enum.filter(fn %{backlinks: backlinks} ->
      slug in Enum.map(backlinks, & &1.slug)
    end)
  end
end
