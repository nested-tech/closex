defmodule Closex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :closex,
      version: "0.2.0",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixirc_paths: elixirc_paths(Mix.env),
      elixir: "~> 1.5",
      description: description(),
      package: package(),
      deps: deps(),
      start_permanent: Mix.env == :prod,
    ]
  end

  def application do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:poison, "~> 3.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:httpoison, "~> 0.13.0"},
      {:exvcr, "~> 0.8", only: :test},
    ]
  end

  defp description() do
    "Close.io HTTP client for Elixir"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Sam Davies", "Darren Oakley"],
      licenses: ["MIT"],
      source_url: "https://github.com/nested-tech/closex",
      homepage_url: "https://github.com/nested-tech/closex",
      links: %{"Nested" => "https://nested.com", "Close.io" => "https://close.io", "GitHub" => "https://github.com/nested-tech/closex"}
    ]
  end
end
