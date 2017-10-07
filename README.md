# Closex

[![CircleCI](https://img.shields.io/circleci/project/github/nextdayproperty/closex.svg)](https://circleci.com/gh/nextdayproperty/closex/tree/master)
[![Package Version](https://img.shields.io/hexpm/v/closex.svg)](https://hex.pm/packages/closex)

Elixir Close.IO client.

Documentation is available on [HexDocs](https://hexdocs.pm/closex).

## Installation

Add `closex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:closex, "~> 0.2.0"}
  ]
end
```

## Configuration

In your config.exs:

```elixir
config :closex,
  api_key: "YOUR_API_KEY"
```

You can also read from an environment variable:

```elixir
config :closex,
  api_key: {:system, "MY_ENV_VAR"}
```
