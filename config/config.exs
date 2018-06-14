# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

if Mix.env() == :test do
  config :closex,
    api_key: System.get_env("CLOSEX_CLOSEIO_API_KEY") || "FAKE_CLOSEIO_TOKEN",
    fallback_client: Closex.MockClient,
    mock_client_fixtures_dir: "test/fixtures",
    sleep_module: Closex.SleepMock

  config :logger, level: :warn
end
