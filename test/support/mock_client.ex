defmodule Closex.MockClient do
  @behaviour Closex.ClientBehaviour

  @moduledoc """
  TODO: Add documentation for using MockClient
  """

  @not_found_id "not_found"

  def get_lead(id, opts \\ [])
  def get_lead(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:error, :mock_not_found}
  end
  def get_lead(id, opts) do
    lead = load("lead.json")
    |> Map.merge(%{"id" => id})
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:ok, lead}
  end

  def get_opportunity(id, opts \\ [])
  def get_opportunity(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_opportunity, [id, opts]}
    {:error, :mock_not_found}
  end
  def get_opportunity(id, opts) do
    opportunity = load("opportunity.json")
    |> Map.merge(%{"id" => id})
    send self(), {:closex_mock_client, :get_opportunity, [id, opts]}
    {:ok, opportunity}
  end

  def get_lead_custom_field(id, opts \\ [])
  def get_lead_custom_field(id = "lcf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c", opts) do
    lead_custom_field = load("lead_custom_field.json")
    send self(), {:closex_mock_client, :get_lead_custom_field, [id, opts]}
    {:ok, lead_custom_field}
  end
  def get_lead_custom_field(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_lead_custom_field, [id, opts]}
    {:error, :mock_not_found}
  end

  def get_organization(id, opts \\ [])
  def get_organization(id = "orga_bwwWG475zqWiQGur0thQshwVXo8rIYecQHDWFanqhen", opts) do
    organization = load("organization.json")
    send self(), {:closex_mock_client, :get_organization, [id, opts]}
    {:ok, organization}
  end
  def get_organization(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_organization, [id, opts]}
    {:error, :mock_not_found}
  end

  def get_lead_statuses(opts \\ []) do
    lead_statuses = load("lead_statuses.json")
    send self(), {:closex_mock_client, :get_lead_statuses, [opts]}
    {:ok, lead_statuses}
  end

  def get_opportunity_statuses(opts \\ []) do
    opportunity_statuses = load("opportunity_statuses.json")
    send self(), {:closex_mock_client, :get_opportunity_statuses, [opts]}
    {:ok, opportunity_statuses}
  end

  def get_users(opts \\ []) do
    users = load("users.json")
    send self(), {:closex_mock_client, :get_users, [opts]}
    {:ok, users}
  end

  # TODO: implement these mocks
  def create_lead(_payload, _opts \\ []), do: :noop
  def update_lead(lead_id, payload, opts \\ []) do
    lead = load("lead.json")
    |> Map.merge(payload)
    |> Map.merge(%{"id" => lead_id})
    send self(), {:closex_mock_client, :update_lead, [lead_id, payload, opts]}
    {:ok, lead}
  end
  def create_opportunity(_payload, _opts \\ []), do: :noop
  def update_opportunity(opportunity_id, payload, opts \\ []) do
    opportunity = load("opportunity.json")
    |> Map.merge(payload)
    |> Map.merge(%{"id" => opportunity_id})
    send self(), {:closex_mock_client, :update_opportunity, [opportunity_id, payload, opts]}
    {:ok, opportunity}
  end
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
