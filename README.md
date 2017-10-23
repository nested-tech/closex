# Closex ✨

[![CircleCI](https://img.shields.io/circleci/project/github/nested-tech/closex.svg)](https://circleci.com/gh/nested-tech/closex/tree/master)
[![Coverage Status](https://img.shields.io/coveralls/nested-tech/closex.svg)](https://coveralls.io/github/nested-tech/closex.svg)
[![Package Version](https://img.shields.io/hexpm/v/closex.svg)](https://hex.pm/packages/closex)
[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://hexdocs.pm/closex/)

Elixir wrapper for the Close.io API with optional caching support.

📔 Learn more about the Close.io API: [http://developer.close.io](http://developer.close.io)

📖 Documentation for this package is available on [HexDocs](https://hexdocs.pm/closex).

## Installation

Add `closex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:closex, ">= 0.0.0"} # or the current stable version
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

## Usage

The client is essentially a wrapper around the Close.IO [REST API](https://developer.close.io/).

It follows the Close.IO API naming conventions as closely as possible. It supports almost everything that the REST API supports including querying leads, opportunities, users, organizations, statuses and more.

Example usage:

```elixir
# Get a lead
Closex.HTTPClient.get_lead("my_lead_id")
{:ok, %{"id" => "my_lead_id", "status_id" => "my_status_id", ...}}

# Update a lead
Closex.HTTPClient.update_lead("my_lead_id", %{status_id: "new_status_id"})
{:ok, %{"id" => "my_lead_id", "status_id" => "new_status_id", ...}}

# With caching
:timer.tc fn -> Closex.CachingClient.get_opportunity_statuses end
{907682, {:loaded, {:ok, %{"data" => [% ...lots of data... ]}}}}
# 900ms response time
:timer.tc fn -> Closex.CachingClient.get_opportunity_statuses end
{17, {:loaded, {:ok, %{"data" => [% ...lots of data... ]}}}}
# 17us response time with caching

# many more ...
```

See [the docs](https://hexdocs.pm/closex) for more examples.

You may also want to set the default client you want to use in your applicaton, either HTTPClient
or CachingClient, via your config:

```
$ cat your_app/config/config.exs

config :yourapp,
  closeio_client: Closex.HTTPClient,
  ...other configuration...
```

Next, use it in your code:

```
$ cat your_app/lib/module_which_uses_closeio.ex

defmodule YourApp.ModuleWhichUsesCloseIO do
  
  @closeio_client Application.fetch_env!(:your_app, :closeio_client)

  def do_things_with_a_close_io_lead(id) do
    @closeio_client.get_lead(id)
    # do things
  end
end
```

## Mock Client

Using the above configuration will allow you to override and use the `Closex.MockClient` in test mode.

For more details on the mock client please see [the docs](https://hexdocs.pm/closex).

## Options

Options will be passed through to [HTTPoison](https://github.com/edgurgel/httpoison#options). For example, to set a shorter timeout:

```elixir
Closex.HTTPClient.get_lead("my_lead_id", timeout: 500, recv_timeout: 1_000)
```

## Mock Client

We have provided a mock client for testing purposes in your application.

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- Report bugs
- Fix bugs and submit pull requests
- Write, clarify, or fix documentation
- Suggest or add new features

## License

MIT

## Copyright

Copyright NextDayProperty Ltd (see LICENSE for details)
