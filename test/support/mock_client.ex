defmodule Closex.MockClient do
  @behaviour Closex.ClientBehaviour

  @moduledoc """
  TODO: Add documentation for using MockClient
  TODO: Expose in hex package
  """

  @not_found_id "not_found"

  def get_lead(id, opts \\ [])
  def get_lead(id = "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O", opts) do
    lead = load("lead.json")
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:ok, lead}
  end
  def get_lead(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:error, :mock_not_found}
  end

  def get_opportunity(id, opts \\ [])
  def get_opportunity(id = "oppo_8eB77gAdf8FMy6GsNHEy84f7uoeEWv55slvUjKQZpJt", opts) do
    lead = load("opportunity.json")
    send self(), {:closex_mock_client, :get_opportunity, [id, opts]}
    {:ok, lead}
  end
  def get_opportunity(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_opportunity, [id, opts]}
    {:error, :mock_not_found}
  end

  def get_lead_custom_field(id, opts \\ [])
  def get_lead_custom_field(id = "lcf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c", opts) do
    lead = load("lead_custom_field.json")
    send self(), {:closex_mock_client, :get_lead_custom_field, [id, opts]}
    {:ok, lead}
  end
  def get_lead_custom_field(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_lead_custom_field, [id, opts]}
    {:error, :mock_not_found}
  end

  def get_organization(id, opts \\ [])
  def get_organization(id = "orga_bwwWG475zqWiQGur0thQshwVXo8rIYecQHDWFanqhen", opts) do
    lead = load("organization.json")
    send self(), {:closex_mock_client, :get_organization, [id, opts]}
    {:ok, lead}
  end
  def get_organization(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_organization, [id, opts]}
    {:error, :mock_not_found}
  end

  def get_lead_statuses(opts \\ []) do
    lead = load("lead_statuses.json")
    send self(), {:closex_mock_client, :get_lead_statuses, [opts]}
    {:ok, lead}
  end

  def get_opportunity_statuses(opts \\ []) do
    opportunity = load("opportunity_statuses.json")
    send self(), {:closex_mock_client, :get_opportunity_statuses, [opts]}
    {:ok, opportunity}
  end

  def get_users(opts \\ []) do
    opportunity = load("users.json")
    send self(), {:closex_mock_client, :get_users, [opts]}
    {:ok, opportunity}
  end

  def create_lead(_payload, _opts \\ []), do: :noop
  def update_lead(_lead_id, _payload, _opts \\ []), do: :noop
  def create_opportunity(_payload, _opts \\ []), do: :noop
  def update_opportunity(_opportunity_id, _payload, _opts \\ []), do: :noop
  def send_email(_payload, _opts \\ []), do: :noop
  def find_leads(_search_term, _opts \\ []), do: :noop

  @fixtures_path Path.join([File.cwd!, "test", "fixtures"])
  defp load(filename) do
    [@fixtures_path, filename]
    |> Path.join
    |> File.read!
    |> Poison.decode!
  end
end
