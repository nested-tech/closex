defmodule Closex.CachexCache do
  @moduledoc """
  Implements a cache using the [Cachex](https://github.com/whitfin/cachex)
  library, for high performance in-memory storage

  It's worth noting that close.io resources are globally unique, so we don't
  need to differentiate between a Lead ID or an Opportunity ID.
  """

  @behaviour Closex.CacheBehaviour

  @doc """
  Fetches a value from the cache for a given key. If it's not in the cache,
  we'll make an API call and populate it using the Closex.fallback_client
  """
  def get(key, {fun, options}) do
    cache_result = Cachex.get(:closex_cache, key, fallback: fn _key ->
      case apply(Closex.fallback_client, fun, options) do
        result = {:ok, _} ->
          {:commit, result}
        error = {:error, _} ->
          {:ignore, error}
      end
    end)

    case cache_result do
      {:loaded, result} ->
        Closex.log fn -> "[Closex.CachexCache] MISS for key: #{key}" end
        result
      {:ok, result} ->
        Closex.log fn -> "[Closex.CachexCache] HIT for key: #{key}" end
        result
      error ->
        Closex.log fn -> "[Closex.CachexCache] ERROR for key: #{key}" end
        {:error, error}
    end
  end

  @doc """
  Sets a specific cache value for a given key
  """
  def set(key, value) do
    {:ok, _} = Cachex.set(:closex_cache, key, value)
    value
  end
end
