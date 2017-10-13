defmodule Closex.Application do
  @moduledoc false

  use Application

  # TODO: make this ttl configurable
  @default_ttl :timer.seconds(15)

  def start(_type, _args) do
    cachex_child_spec = %{
      id: :closex_cache,
      start: {Cachex, :start_link, [:closex_cache, [default_ttl: @default_ttl]]},
    }
    children = [
      cachex_child_spec
    ]
    opts = [strategy: :one_for_one, name: Closex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
