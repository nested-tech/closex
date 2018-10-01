defmodule Closex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :closex,
      version: "1.1.1",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixir: "~> 1.6",
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [mod: {Closex.Application, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, ">= 1.0.0"},
      {:httpoison, ">= 0.0.0"},
      {:exvcr, ">= 0.8.0", only: :test, optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, optional: true},
      {:excoveralls, ">= 0.4.0", only: :test, optional: true},
      {:dialyxir, ">= 0.0.0", runtime: false, optional: true},
      {:mix_test_watch, ">= 0.3.0", only: :dev, runtime: false, optional: true}
    ]
  end

  defp description() do
    "Close.io HTTP client for Elixir"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: [
        "Sam Davies",
        "Darren Oakley",
        "Morgan Sadr-Hashemi",
        "Adam Lancaster",
        "Ed Saunders"
      ],
      licenses: ["MIT"],
      source_url: "https://github.com/nested-tech/closex",
      homepage_url: "https://github.com/nested-tech/closex",
      links: %{
        "Nested" => "https://nested.com",
        "Close.io" => "https://close.io",
        "GitHub" => "https://github.com/nested-tech/closex"
      }
    ]
  end
end
