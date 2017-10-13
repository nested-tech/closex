defmodule Closex.MockClient do
  # @behaviour Closex.ClientBehaviour

  def get_lead(id = "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O", opts \\ []) do
    lead = load("lead.json")
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:ok, lead}
  end
  def get_lead(id = "not_found", opts) do
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:error, :not_found}
  end

  @fixtures_path Path.join([File.cwd!, "test", "fixtures"])
  defp load(filename) do
    [@fixtures_path, filename]
    |> Path.join
    |> File.read!
    |> Poison.decode!
  end
end
