# Closex ✨

[![CircleCI](https://img.shields.io/circleci/project/github/nested-tech/closex.svg)](https://circleci.com/gh/nested-tech/closex/tree/master)
[![Coverage Status](https://img.shields.io/coveralls/nested-tech/closex.svg)](https://coveralls.io/github/nested-tech/closex.svg)
[![Package Version](https://img.shields.io/hexpm/v/closex.svg)](https://hex.pm/packages/closex)
[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://hexdocs.pm/closex/)

🔥 Blazing-fast 🚀 Elixir library 👻️ for the Close.io API 🤖

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
  # This should be accessible from your user's account page in close.io
  api_key: "YOUR_API_KEY",

  # This is a beta feature which will wait and retry `find_lead` and
  # `find_opportunity` requests *once* if you hit your rate limit. The intention
  # is that this will be gradually rolled out across other requests as needed.
  rate_limit_retry: true # Defaults to `false` (don't retry)
```

You can also read the API key from an environment variable, such as:

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

# many more ...
```

See [the docs](https://hexdocs.pm/closex) for more examples.

You may also want to set the default client you want to use in your applicaton via your config:

```
# your_app/config/config.exs

config :yourapp,
  closeio_client: Closex.HTTPClient,
  ...other configuration...
```

Next, use it in your code:

```
# your_app/lib/module_which_uses_closeio.ex

defmodule YourApp.ModuleWhichUsesCloseIO do

  @closeio_client Application.fetch_env!(:your_app, :closeio_client)

  def do_things_with_a_close_io_lead(id) do
    @closeio_client.get_lead(id)
    # do things
  end
end
```

## Mock Client

We have provided a mock client for testing purposes in your application.

Using the above configuration will allow you to override and use the `Closex.MockClient` in test mode.

```
# your_app/config/test.exs

config :yourapp,
  closeio_client: Closex.MockClient,
  ...other configuration...
```

For more details on the mock client please see [the docs](https://hexdocs.pm/closex).

## Options

Options will be passed through to [HTTPoison](https://github.com/edgurgel/httpoison#options). For example, to set a shorter timeout:

```elixir
Closex.HTTPClient.get_lead("my_lead_id", timeout: 500, recv_timeout: 1_000)
```

### Rate limit retry

When we hit a rate limit on certain requests, there's a beta configuration to get the client to take this into account, wait a second longer than the remaining rate limit window then retry again. This can be enabled for all affected requests (see [Configuration](#configuration)) or on a per-request basis:

```elixir
Closex.HTTPClient.get_lead("my_lead_id", rate_limit_retry: true)
```

This is only limited to certain requests as it's being trialled, if useful then we'll roll it out across other requests. The requests are:

- `find_leads`
- `find_opportunities`
- `find_all_opportunities`
- `get_users`

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- Report bugs
- Fix bugs and submit pull requests
- Write, clarify, or fix documentation
- Suggest or add new features
- Please use the git hooks provided in the hooks directory. Use the following command to set these hooks up.

```
ln -s ../../hooks/pre-commit.sh .git/hooks/pre-commit
```

## License

MIT

## Copyright

Copyright NextDayProperty Ltd (see LICENSE for details)
