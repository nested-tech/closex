# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

if Mix.env == :test do
  config :closex,
    api_key: "FAKE_CLOSEIO_TOKEN",
    fallback_client: Closex.MockClient
end
