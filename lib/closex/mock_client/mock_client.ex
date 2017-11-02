defmodule Closex.MockClient do
  @behaviour Closex.ClientBehaviour

  @moduledoc """
  This module is for testing, it allows you to stub requests to CloseIO.

  It behaves like the standard client so you can drop it into your code via
  configuration in your testing environment, but it will return the test objects for each method.

  It gets these test objects from json files, for more detail see the `test/fixtures/*.json` files.

  However, you can override the response of the mock client with json more specific to your domain:

  ```
  # your_app/config/test.exs

  config :yourapp,
    closeio_client: Closex.MockClient,
    ...other configuration...

  config :closex,
    mock_client_fixtures_dir: Path.join([File.cwd!, "path", "to", "your", "fixtures"])
  ```

  If you'd like to emulate not finding an object, pass in the `Closex.MockClient.not_found_id` value.

  For specific examples please see the documentation for the method you're using.
  """

  @not_found_id "not_found"
  def not_found_id, do: @not_found_id

  @lead_id "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O"
  def lead_id, do: @lead_id

  @opportunity_id "oppo_8eB77gAdf8FMy6GsNHEy84f7uoeEWv55slvUjKQZpJt"
  def opportunity_id, do: @opportunity_id

  @lead_custom_field_id "lcf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c"
  def lead_custom_field_id, do: @lead_custom_field_id

  @organization_id "orga_bwwWG475zqWiQGur0thQshwVXo8rIYecQHDWFanqhen"
  def organization_id, do: @organization_id

  @search_term "foo"
  def search_term, do: @search_term

  @doc """
  Gets a lead from CloseIO.

  Returns `{:ok, lead}`.

  You can hand in any lead id you like and it will return an example lead with that id.

  We have provided an example id to use when the id doesn't matter to you.

  ## Examples

    > Closex.MockClient.get_lead(Closex.MockClient.lead_id())
    ...contents of test/fixtures/lead.json...

    iex> Closex.MockClient.get_lead(Closex.MockClient.not_found_id())
    {:error, :mock_not_found}
  """
  def get_lead(id, opts \\ [])

  def get_lead(id = @not_found_id, opts) do
    send(self(), {:closex_mock_client, :get_lead, [id, opts]})
    {:error, :mock_not_found}
  end

  def get_lead(id, opts) do
    lead =
      load("lead.json")
      |> Map.merge(%{"id" => id})

    send(self(), {:closex_mock_client, :get_lead, [id, opts]})
    {:ok, lead}
  end

  @doc """
  Gets an opportunity from CloseIO.

  Returns `{:ok, opportunity}`.

  You can hand in any opportunity id you like and it will return an example opportunity with that id.

  We have provided an example id to use when the id doesn't matter to you.

  ## Examples

    > Closex.MockClient.get_opportunity(Closex.MockClient.opportunity_id())
    ...contents of test/fixtures/opportunity.json...

    iex> Closex.MockClient.get_opportunity(Closex.MockClient.not_found_id())
    {:error, :mock_not_found}
  """
  def get_opportunity(id, opts \\ [])

  def get_opportunity(id = @not_found_id, opts) do
    send(self(), {:closex_mock_client, :get_opportunity, [id, opts]})
    {:error, :mock_not_found}
  end

  def get_opportunity(id, opts) do
    opportunity =
      load("opportunity.json")
      |> Map.merge(%{"id" => id})

    send(self(), {:closex_mock_client, :get_opportunity, [id, opts]})
    {:ok, opportunity}
  end

  @doc """
  Gets a lead custom field from CloseIO.

  Returns `{:ok, lead_custom_field}`.

  You can hand in any custom field id you like and it will return an example custom field with that id.

  We have provided an example id to use when the id doesn't matter to you.

  ## Examples

    > Closex.MockClient.get_lead_custom_field(Closex.MockClient.lead_custom_field_id())
    ...contents of test/fixtures/lead_custom_field.json...

    iex> Closex.MockClient.get_lead_custom_field(Closex.MockClient.not_found_id())
    {:error, :mock_not_found}
  """
  def get_lead_custom_field(id, opts \\ [])

  def get_lead_custom_field(id = @not_found_id, opts) do
    send(self(), {:closex_mock_client, :get_lead_custom_field, [id, opts]})
    {:error, :mock_not_found}
  end

  def get_lead_custom_field(id, opts) do
    lead_custom_field =
      load("lead_custom_field.json")
      |> Map.merge(%{"id" => id})

    send(self(), {:closex_mock_client, :get_lead_custom_field, [id, opts]})
    {:ok, lead_custom_field}
  end

  @doc """
  Gets an organization from CloseIO.

  Returns `{:ok, organization}`.

  You can hand in any organization id you like and it will return an example organization with that id.

  We have provided an example id to use when the id doesn't matter to you.

  ## Examples

    > Closex.MockClient.get_organization(Closex.MockClient.organization_id())
    ...contents of test/fixtures/organization.json...

    iex> Closex.MockClient.get_organization(Closex.MockClient.not_found_id())
    {:error, :mock_not_found}
  """
  def get_organization(id, opts \\ [])

  def get_organization(id = @not_found_id, opts) do
    send(self(), {:closex_mock_client, :get_organization, [id, opts]})
    {:error, :mock_not_found}
  end

  def get_organization(id, opts) do
    organization =
      load("organization.json")
      |> Map.merge(%{"id" => id})

    send(self(), {:closex_mock_client, :get_organization, [id, opts]})
    {:ok, organization}
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
    send(self(), {:closex_mock_client, :get_lead_statuses, [opts]})
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
    send(self(), {:closex_mock_client, :get_opportunity_statuses, [opts]})
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
    send(self(), {:closex_mock_client, :get_users, [opts]})
    {:ok, users}
  end

  @doc """
  Creates a lead in CloseIO.

  Returns `{:ok, lead}`

  ## Examples

    > Closex.MockClient.create_lead(%{})
    ...contents of test/fixtures/create_lead.json...
  """
  def create_lead(payload, opts \\ []) do
    lead = load("create_lead.json")
    send(self(), {:closex_mock_client, :create_lead, [payload, opts]})
    {:ok, lead}
  end

  @doc """
  Update a lead in CloseIO.

  Returns `{:ok, lead}`.

  You can hand in any lead id you like and it will return an example lead with that id, with your updates merged in.
  Any dates you hand in to be merged will be parsed to strings when they are returned.

  We have provided an example id to use when the id doesn't matter to you.

  ## Examples

    > Closex.MockClient.update_lead(Closex.MockClient.lead_id(), %{})
    ...contents of test/fixtures/organization.json...

    iex> Closex.MockClient.update_lead(Closex.MockClient.not_found_id(), %{})
    {:error, :mock_not_found}

    iex> Closex.MockClient.update_lead(Closex.MockClient.not_found_id(), %{"foo" => "bar"})
    {:error, :mock_not_found}
  """
  def update_lead(lead_id, payload, opts \\ [])

  def update_lead(@not_found_id, _payload, _opts) do
    {:error, :mock_not_found}
  end

  def update_lead(lead_id, payload, opts) do
    lead =
      load("lead.json")
      |> Map.merge(payload)
      |> Map.merge(%{"id" => lead_id})

    lead = parse_dates_to_strings(lead)
    send(self(), {:closex_mock_client, :update_lead, [lead_id, payload, opts]})
    {:ok, lead}
  end

  @doc """
  Creates an opportunity in CloseIO.

  Returns `{:ok, opportunity}`

  ## Examples

    > Closex.MockClient.create_opportunity(%{})
    ...contents of test/fixtures/create_opportunity.json...
  """
  def create_opportunity(payload, opts \\ []) do
    opportunity = load("create_opportunity.json")
    send(self(), {:closex_mock_client, :create_opportunity, [payload, opts]})
    {:ok, opportunity}
  end

  @doc """
  Update an Opportunity in CloseIO.

  Returns `{:ok, opportunity}`.

  You can hand in any opportunity id you like and it will return an example opportunity with that id, with your updates merged in.

  We have provided an example id to use when the id doesn't matter to you.

  ## Examples

    > Closex.MockClient.update_opportunity(Closex.MockClient.opportunity_id(), %{})
    ...contents of test/fixtures/organization.json...

    iex> Closex.MockClient.update_opportunity(Closex.MockClient.not_found_id(), %{})
    {:error, :mock_not_found}

    iex> Closex.MockClient.update_opportunity(Closex.MockClient.not_found_id(), %{"foo" => "bar"})
    {:error, :mock_not_found}
  """
  def update_opportunity(_opportunity_id, _payload, _opts \\ [])

  def update_opportunity(@not_found_id, _payload, _opts) do
    {:error, :mock_not_found}
  end

  def update_opportunity(opportunity_id, payload, opts) do
    opportunity =
      load("opportunity.json")
      |> Map.merge(payload)
      |> Map.merge(%{"id" => opportunity_id})

    send(self(), {:closex_mock_client, :update_opportunity, [opportunity_id, payload, opts]})
    {:ok, opportunity}
  end

  @doc """
  Sends an email CloseIO.

  Returns `{:ok, email}`

  ## Examples

    > Closex.MockClient.send_email(%{})
    ...contents of test/fixtures/send_email.json...
  """
  def send_email(payload, opts \\ []) do
    email =
      load("send_email.json")
      |> Map.merge(payload)

    send(self(), {:closex_mock_client, :send_email, [payload, opts]})
    {:ok, email}
  end

  @doc """
  Finds a lead in CloseIO.

  Returns `{:ok, leads}`.

  You can hand in any search term you like and it will return an example search which finds one example lead.

  You can also search for something you are not expecting to find with our not_found_id. This will provide the empty
  result set in find_no_leads.json.

  We have provided an example search term to use when the search term doesn't matter to you.

  ## Examples

    > Closex.MockClient.update_opportunity(Closex.MockClient.search_term())
    ...contents of test/fixtures/find_leads.json...

    > Closex.MockClient.update_opportunity(Closex.MockClient.not_found_id())
    ...contents of test/fixtures/find_no_leads.json...
  """
  def find_leads(search_term, opts \\ [])

  def find_leads(search_term = @not_found_id, opts) do
    leads = load("find_no_leads.json")
    send(self(), {:closex_mock_client, :find_leads, [search_term, opts]})
    {:ok, leads}
  end

  def find_leads(search_term, opts) do
    leads = load("find_leads.json")
    send(self(), {:closex_mock_client, :find_leads, [search_term, opts]})
    {:ok, leads}
  end

  defp load(filename) do
    case Application.fetch_env(:closex, :mock_client_fixtures_dir) do
      {:ok, fixtures_path} ->
        file =
          [fixtures_path, filename]
          |> Path.join()
          |> File.read()

        case file do
          {:ok, binary} ->
            Poison.decode!(binary)

          {:error, _} ->
            load_default(filename)
        end

      :error ->
        load_default(filename)
    end
  end

  defp parse_dates_to_strings(lead) do
    Enum.into(lead, %{}, fn {key, value} ->
      case {key, value} do
        {key, %Date{}} ->
          {key, Date.to_string(value)}

        {key, %DateTime{}} ->
          {key, DateTime.to_string(value)}

        {_, _} ->
          {key, value}
      end
    end)
  end

  defp load_default(filename) do
    Path.join([__DIR__, "fixtures", filename])
    |> File.read!()
    |> Poison.decode!()
  end
end
