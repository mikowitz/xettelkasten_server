defmodule XettelkastenServer.GitBehaviour do
  @moduledoc false

  @callback add(integer()) :: {:ok, map()} | {:error, binary()}
  @callback commit(map()) :: {:ok, map()} | {:error, binary()}
  @callback push(map()) :: {:ok, map()} | {:error, binary()}
end
