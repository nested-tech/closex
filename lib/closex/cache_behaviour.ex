defmodule Closex.CacheBehaviour do
  @moduledoc """
  There are more than one potential caching strategies and libraries, but we'd
  like to be able to switch between them where appropriate. This class defines
  the interface for our caching layer.
  """

  @type id :: String.t
  @type options :: Keyword.t
  @type close_io_function :: atom

  @callback get(id, {close_io_function, options}) :: term
  @callback set(id, term) :: term
end
