defmodule Closex.RedisCache do
  @moduledoc """
  Implements a cache using mnesia in order to allow for a distributed cache
  """

  @behaviour Closex.CacheBehaviour

  def get(key, {fun, options}) do
    case Redix.command(:redix, ["GET", key]) do
      {:ok, nil}
        -> case apply(Closex.fallback_client, fun, options) do
          {:ok, response} -> {:ok, set(key, response)}
          {:error, error} -> {:error, error}
        end
      {:ok, value} ->
        {:ok, :erlang.binary_to_term(value)}
    end
  end

  def set(key, response) do
    binary_response = :erlang.term_to_binary(response)
    Redix.command(:redix, ["SET", key, binary_response])
    response
  end
end

