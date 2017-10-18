defmodule Closex.MnesiaCache do
  @moduledoc """
  Implements a cache using mnesia in order to allow for a distributed cache
  """

  @behaviour Closex.CacheBehaviour

  alias :mnesia, as: Mnesia

  def get(key, {fun, options}) do
    :noop
  end

  def set(key, {fun, options}) do
    :noop
  end
end
