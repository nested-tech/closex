defmodule Closex.MockClient do
  @behaviour Closex.ClientBehaviour

  @not_found_id "not_found"

  def get_lead(id = "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O", opts \\ []) do
    lead = load("lead.json")
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:ok, lead}
  end
  def get_lead(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:error, :mock_not_found}
  end

  def get_opportunity(id = "oppo_8eB77gAdf8FMy6GsNHEy84f7uoeEWv55slvUjKQZpJt", opts \\ []) do
    lead = load("opportunity.json")
    send self(), {:closex_mock_client, :get_opportunity, [id, opts]}
    {:ok, lead}
  end
  def get_opportunity(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_opportunity, [id, opts]}
    {:error, :mock_not_found}
  end

  @fixtures_path Path.join([File.cwd!, "test", "fixtures"])
  defp load(filename) do
    [@fixtures_path, filename]
    |> Path.join
    |> File.read!
    |> Poison.decode!
  end
end
