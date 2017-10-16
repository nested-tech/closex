defmodule Closex do
  @moduledoc """
  Close.IO client.
  """
  require Logger

  def log(fun, level \\ :debug) when is_function(fun) do
    log? = Application.get_env(:closex, :logging, true)

    if log? do
      Logger.log(level, fun)
    end
  end
end
