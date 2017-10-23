defmodule Closex.MockClient do
  @behaviour Closex.ClientBehaviour

  @moduledoc """
  This module is for testing, it allows you to stub requests to CloseIO.

  It behaves like the standard client so you can drop it into your code via
  configuration in your testing environment.

  In test mode you can set the MockClient:

  ```
  $ cat your_app/config/test.exs

  config :yourapp,
    closeio_client: Closex.MockClient,
    ...other configuration...
  ```

  The mock client will return the test values for each method.

  For more detail on the test objects see the `test/fixtures/*.json` files.

  However, you can override the response of the mock client with json more specific to your domain:

  ```
  $ cat your_app/config/test.exs

  config :yourapp,
    closeio_client: Closex.MockClient,
    ...other configuration...

  config :closex,
    mock_client_fixtures_dir: Path.join([File.cwd!, "path", "to", "your", "fixtures"])
  ```

  If you'd like to emulate not finding an object, pass in the `Closex.MockClient.not_found_id` value.
  """

  @not_found_id "not_found"
  def not_found_id do
    @not_found_id
  end

  @lead_id "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O"
  def lead_id do
    @lead_id
  end

  @opportunity_id "oppo_8eB77gAdf8FMy6GsNHEy84f7uoeEWv55slvUjKQZpJt"
  def opportunity_id do
    @opportunity_id
  end

  @lead_custom_field_id "lcf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c"
  def lead_custom_field_id do
    @lead_custom_field_id
  end

  @organization_id "orga_bwwWG475zqWiQGur0thQshwVXo8rIYecQHDWFanqhen"
  def organization_id do
    @organization_id
  end

  @doc """
  Gets a lead from CloseIO.

  Returns `{:ok, lead}`.

  ## Examples

    > Closex.MockClient.get_lead(Closex.MockClient.lead_id())
    ...contents of test/fixtures/lead.json...

    iex> Closex.MockClient.get_lead(Closex.MockClient.not_found_id())
    {:error, :mock_not_found}
  """
  def get_lead(id, opts \\ [])
  def get_lead(id = @lead_id, opts) do
    lead = load("lead.json")
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:ok, lead}
  end
  def get_lead(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_lead, [id, opts]}
    {:error, :mock_not_found}
  end

  @doc """
  Gets an opportunity from CloseIO.

  Returns `{:ok, opportunity}`.

  ## Examples

    > Closex.MockClient.get_opportunity(Closex.MockClient.opportunity_id())
    ...contents of test/fixtures/opportunity.json...

    iex> Closex.MockClient.get_opportunity(Closex.MockClient.not_found_id())
    {:error, :mock_not_found}
  """
  def get_opportunity(id, opts \\ [])
  def get_opportunity(id = @opportunity_id, opts) do
    opportunity = load("opportunity.json")
    send self(), {:closex_mock_client, :get_opportunity, [id, opts]}
    {:ok, opportunity}
  end
  def get_opportunity(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_opportunity, [id, opts]}
    {:error, :mock_not_found}
  end

  @doc """
  Gets a lead custom field from CloseIO.

  Returns `{:ok, lead_custom_field}`.

  ## Examples

    > Closex.MockClient.get_lead_custom_field(Closex.MockClient.lead_custom_field_id())
    ...contents of test/fixtures/lead_custom_field.json...

    iex> Closex.MockClient.get_lead_custom_field(Closex.MockClient.not_found_id())
    {:error, :mock_not_found}
  """
  def get_lead_custom_field(id, opts \\ [])
  def get_lead_custom_field(id = @lead_custom_field_id, opts) do
    lead_custom_field = load("lead_custom_field.json")
    send self(), {:closex_mock_client, :get_lead_custom_field, [id, opts]}
    {:ok, lead_custom_field}
  end
  def get_lead_custom_field(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_lead_custom_field, [id, opts]}
    {:error, :mock_not_found}
  end

  @doc """
  Gets an organization from CloseIO.

  Returns `{:ok, organization}`.

  ## Examples

    > Closex.MockClient.get_organization(Closex.MockClient.organization_id())
    ...contents of test/fixtures/organization.json...

    iex> Closex.MockClient.get_organization(Closex.MockClient.not_found_id())
    {:error, :mock_not_found}
  """
  def get_organization(id, opts \\ [])
  def get_organization(id = @organization_id, opts) do
    organization = load("organization.json")
    send self(), {:closex_mock_client, :get_organization, [id, opts]}
    {:ok, organization}
  end
  def get_organization(id = @not_found_id, opts) do
    send self(), {:closex_mock_client, :get_organization, [id, opts]}
    {:error, :mock_not_found}
  end

  @doc """
  Gets the potential statuses of a lead from CloseIO.

  Returns `{:ok, lead_statuses}`.

  ## Examples

    > Closex.MockClient.get_lead_statuses()
    ...contents of test/fixtures/lead_statuses.json...
  """
  def get_lead_statuses(opts \\ []) do
    lead_statuses = load("lead_statuses.json")
    send self(), {:closex_mock_client, :get_lead_statuses, [opts]}
    {:ok, lead_statuses}
  end

  @doc """
  Gets the potential statuses of an opportunity from CloseIO.

  Returns `{:ok, opportunity_statuses}`.

  ## Examples

    > Closex.MockClient.get_opportunity_statuses()
    ...contents of test/fixtures/opportunity_statuses.json...
  """
  def get_opportunity_statuses(opts \\ []) do
    opportunity_statuses = load("opportunity_statuses.json")
    send self(), {:closex_mock_client, :get_opportunity_statuses, [opts]}
    {:ok, opportunity_statuses}
  end

  @doc """
  Gets the users available in CloseIO.

  Returns `{:ok, users}`.

  ## Examples

    > Closex.MockClient.get_users()
    ...contents of test/fixtures/users.json...
  """
  def get_users(opts \\ []) do
    users = load("users.json")
    send self(), {:closex_mock_client, :get_users, [opts]}
    {:ok, users}
  end

  # TODO: Mock functions which pass through to default client
  def create_lead(payload, opts \\ []), do: Closex.HTTPClient.create_lead(payload, opts)

  def update_lead(lead_id, payload, opts \\ [])
  def update_lead(lead_id = @lead_id, payload, opts) do
    lead = load("lead.json")
    |> Map.merge(payload)
    send self(), {:closex_mock_client, :update_lead, [lead_id, payload, opts]}
    {:ok, lead}
  end
  def update_lead(@not_found_id, _payload, _opts) do
    {:error, :mock_not_found}
  end

  def create_opportunity(payload, opts \\ []), do: Closex.HTTPClient.create_opportunity(payload, opts)

  def update_opportunity(_opportunity_id, _payload, _opts \\ [])
  def update_opportunity(opportunity_id = @opportunity_id, payload, opts) do
    opportunity = load("opportunity.json")
    |> Map.merge(payload)
    send self(), {:closex_mock_client, :update_opportunity, [opportunity_id, payload, opts]}
    {:ok, opportunity}
  end
  def update_opportunity(@not_found_id, _payload, _opts) do
    {:error, :mock_not_found}
  end

  def send_email(payload, opts \\ []), do: Closex.HTTPClient.send_email(payload, opts)
  def find_leads(search_term, opts \\ []), do: Closex.HTTPClient.find_leads(search_term, opts)

  @fixtures_path Application.get_env(:closex, :mock_client_fixtures_dir, Path.join([File.cwd!, "lib", "closex", "mock_client", "fixtures"]))
  defp load(filename) do
    [@fixtures_path, filename]
    |> Path.join
    |> File.read!
    |> Poison.decode!
  end
end
