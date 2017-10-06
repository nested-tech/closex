# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :closex,
  base_url: "https://app.close.io/api/v1"

if Mix.env == :test do
  config :closex,
    api_key: "FAKE_CLOSEIO_TOKEN" # dev key for testing
end

#     import_config "#{Mix.env}.exs"
