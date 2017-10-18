defmodule Closex do
  @moduledoc """
  Close.IO client.
  """
  require Logger

  @doc "The internal client library used for making calls to the close.io API."
  def fallback_client do
    Application.get_env(:closex, :fallback_client, Closex.HTTPClient)
  end

  @doc """
  The internal cache used to avoid making unnecessary calls to close.io.

  There is currently only one cache implementation using cachex. This is very
  fast and great as an in-memory cache, but it does not provide a way to manage
  a distributed cache. This abstraction allows us to extend and experiment with
  different caching strategies while still having a reasonable fallback.
  """
  def cache do
    case Application.get_env(:closex, :cache) do
      "cachex" -> Closex.CachexCache
      "mnesia" -> Closex.MnesiaCache
    end
  end

  @doc "Log using standard Logger"
  def log(fun, level \\ :debug) when is_function(fun) do
    log? = Application.get_env(:closex, :logging, true)

    if log? do
      Logger.log(level, fun)
    end
  end
end
