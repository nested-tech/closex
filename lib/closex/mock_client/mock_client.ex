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

  @not_found_query "Jasdeep singh ptjasdeepsingh@gmail.com"
  def not_found_query, do: @not_found_query

  @multiple_results_query "Fred Flintstone fred.flintstone@gmail.com"
  def multiple_results_query, do: @multiple_results_query

  @timeout_query "mock_timeout"
  def timeout_query, do: @timeout_query

  @lead_id "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O"
  def lead_id, do: @lead_id

  @opportunity_id "oppo_8eB77gAdf8FMy6GsNHEy84f7uoeEWv55slvUjKQZpJt"
  def opportunity_id, do: @opportunity_id

  @lead_custom_field_id "lcf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c"
  def lead_custom_field_id, do: @lead_custom_field_id

  @organization_id "orga_bwwWG475zqWiQGur0thQshwVXo8rIYecQHDWFanqhen"
  def organization_id, do: @organization_id

  @doc """
  Gets a lead from CloseIO.

  Returns `{:ok, lead}`.

  You can hand in any lead id you like and it will return an example lead with that id.

  We have provided an example id to use when the id doesn't matter to you.

  ## Examples

    > Closex.MockClient.get_lead(Closex.MockClient.lead_id())
    ...contents of test/fixtures/lead.json...

    iex> Closex.MockClient.get_lead(Closex.MockClient.not_found_id())
    {:error, "Empty query: Lead matching query does not exist."}

    iex> Closex.MockClient.get_lead(Closex.MockClient.timeout_query())
    {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  """
  def get_lead(id, opts \\ [])

  def get_lead(id = @not_found_id, opts) do
    send(self(), {:closex_mock_client, :get_lead, [id, opts]})
    {:error, "Empty query: Lead matching query does not exist."}
  end

  def get_lead(id = @timeout_query, opts) do
    send(self(), {:closex_mock_client, :get_lead, [id, opts]})
    {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  end

  def get_lead(id = @lead_id, opts) do
    lead =
      load("lead.json")
      |> Map.put("id", id)

    send(self(), {:closex_mock_client, :get_lead, [id, opts]})
    {:ok, lead}
  end

  def get_lead(id, opts) do
    lead =
      load("#{id}.json")
      |> Map.put("id", id)

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
    {:error, "Empty query: Lead matching query does not exist."}
  """
  def get_opportunity(id, opts \\ [])

  def get_opportunity(id = @not_found_id, opts) do
    send(self(), {:closex_mock_client, :get_opportunity, [id, opts]})
    {:error, "Empty query: Lead matching query does not exist."}
  end

  def get_opportunity(id, opts) do
    opportunity =
      load("opportunity.json")
      |> Map.put("id", id)

    send(self(), {:closex_mock_client, :get_opportunity, [id, opts]})
    {:ok, opportunity}
  end

  def get_opportunities(_opts) do
    {:ok, []}
  end

  def find_all_opportunities(term, limit \\ 10) do
    send(self(), {:closex_mock_client, :find_all_opportunities, [term, limit]})
    {:ok, load("#{term}_opportunity.json")}
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
    {:error, "Empty query: LeadCustomField matching query does not exist."}
  """
  def get_lead_custom_field(id, opts \\ [])

  def get_lead_custom_field(id = @not_found_id, opts) do
    send(self(), {:closex_mock_client, :get_lead_custom_field, [id, opts]})
    {:error, "Empty query: LeadCustomField matching query does not exist."}
  end

  def get_lead_custom_field(id, opts) do
    lead_custom_field =
      load("lead_custom_field.json")
      |> Map.put("id", id)

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
    {:error, "Empty query: Organization matching query does not exist."}
  """
  def get_organization(id, opts \\ [])

  def get_organization(id = @not_found_id, opts) do
    send(self(), {:closex_mock_client, :get_organization, [id, opts]})
    {:error, "Empty query: Organization matching query does not exist."}
  end

  def get_organization(id, opts) do
    organization =
      load("organization.json")
      |> Map.put("id", id)

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
    %{"contacts" => [lead_contact]} = lead
    %{"contacts" => [primary_payload_contact | other_payload_contacts]} = payload
    contact = Map.merge(lead_contact, primary_payload_contact)

    merged_lead =
      Map.merge(lead, payload)
      |> Map.merge(%{"contacts" => [contact | other_payload_contacts]})

    send(self(), {:closex_mock_client, :create_lead, [payload, opts]})
    {:ok, merged_lead}
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
    {:error, "Empty query: Lead matching query does not exist."}

    iex> Closex.MockClient.update_lead(Closex.MockClient.not_found_id(), %{"foo" => "bar"})
    {:error, "Empty query: Lead matching query does not exist."}
  """
  def update_lead(lead_id, payload, opts \\ [])

  def update_lead(@not_found_id, _payload, _opts) do
    {:error, "Empty query: Lead matching query does not exist."}
  end

  def update_lead(lead_id = @timeout_query, payload, opts) do
    send(self(), {:closex_mock_client, :update_lead, [lead_id, payload, opts]})
    {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  end

  def update_lead(lead_id, payload, opts) do
    lead =
      load("lead.json")
      |> Map.merge(payload)
      |> Map.put("id", lead_id)

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
    {:error, "Empty query: Opportunity matching query does not exist."}

    iex> Closex.MockClient.update_opportunity(Closex.MockClient.not_found_id(), %{"foo" => "bar"})
    {:error, "Empty query: Opportunity matching query does not exist."}
  """
  def update_opportunity(_opportunity_id, _payload, _opts \\ [])

  def update_opportunity(@not_found_id, _payload, _opts) do
    {:error, "Empty query: Opportunity matching query does not exist."}
  end

  def update_opportunity(opportunity_id, payload, opts) do
    opportunity =
      load("opportunity.json")
      |> Map.merge(payload)
      |> Map.put("id", opportunity_id)

    send(self(), {:closex_mock_client, :update_opportunity, [opportunity_id, payload, opts]})
    {:ok, opportunity}
  end

  @doc """
  Stubs creation of a task for the given lead with the given text on Close.IO.

  Returns `{:ok, task} or `{:error, error}` (possible errors are lead not found and HTTP timeout on using `not_found_id` and `timeout_query` respectively as `lead_id`)

  By default, the task returned is the contents of `test/fixtures/task.json` but with the lead id and text provided in the arguments.

  Any optional parameters permitted in the [Close.IO API](https://developer.close.io/#tasks-create-a-task) will be merged into the resulting task and all others will be omitted.

  ## Examples

    > Closex.MockClient.create_task(Closex.MockClient.lead_id(), "I am task", %{})
    ...contents of test/fixtures/organization.json (with ID lead_id() and text "I am task")...

    > Closex.MockClient.create_task(Closex.MockClient.lead_id(), "I am task", %{assigned_to: "busy user", foo: "bar"})
    ...contents of test/fixtures/organization.json (with ID lead_id(), text "I am task" and assigned_to "busy_user")...

    iex> Closex.MockClient.create_task(Closex.MockClient.not_found_id(), "I am task", %{assigned_to: "busy user", foo: "bar"})
    {:error, %{"errors" => [], "field-errors" => %{"lead" => "Object does not exist."}}}

    iex> Closex.MockClient.create_task(Closex.MockClient.timeout_query(), "I am task", %{assigned_to: "busy user", foo: "bar"})
    {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  """
  def create_task(lead_id, text, params \\ %{}, opts \\ [])

  def create_task(@not_found_id, text, params, opts) do
    send(self(), {:closex_mock_client, :create_task, [@not_found_id, text, params, opts]})

    {:error,
     %{
       "errors" => [],
       "field-errors" => %{"lead" => "Object does not exist."}
     }}
  end

  def create_task(@timeout_query, text, params, opts) do
    send(self(), {:closex_mock_client, :create_task, [@timeout_query, text, params, opts]})
    {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  end

  def create_task(lead_id, text, params, opts) do
    valid_param_keys = [
      :_type,
      :lead_id,
      :assigned_to,
      :text,
      :date,
      :is_complete
    ]

    final_params =
      for {k, v} <- params, k in valid_param_keys, do: {Atom.to_string(k), v}, into: %{}

    task =
      load("task.json")
      |> Map.merge(%{"lead_id" => lead_id, "text" => text})
      |> Map.merge(final_params)

    send(self(), {:closex_mock_client, :create_task, [lead_id, text, params, opts]})
    {:ok, task}
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
  Stubs finding leads in CloseIO.

  Returns `{:ok, leads}` or `{:error, error}` tuple.

  ## Examples

  By default, this returns the contents of the `find_one_lead.json` fixture.

      > Closex.MockClient.find_leads("foo")
      ...contents of test/fixtures/find_one_lead.json...

  Specific search results can be returned by storing a response in your
  `test/fixtures` directly which corresponds to the specific query. It **must**
  be named `find_leads_<search>.json`, otherwise we will use default. Note, we
  turn spaces into underscores.

      > Closex.MockClient.find_leads("some lead")
      ...contents of test/fixtures/find_leads_some_lead.json

  Additional helper queries available are:

      iex> Closex.MockClient.find_leads(Closex.MockClient.not_found_query())
      {:ok, %{"data" => [], "has_more" => false, "total_results" => 0}}

      > Closex.MockClient.find_leads(Closex.MockClient.multiple_results_query())
      ...contents of test/fixtures/find_multiple_leads.json...

      iex> Closex.MockClient.find_leads(Closex.MockClient.timeout_query())
      {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  """
  def find_leads(search_term, opts \\ [])

  def find_leads(search_term = @not_found_query, opts) do
    leads = load("find_no_leads.json")
    send(self(), {:closex_mock_client, :find_leads, [search_term, opts]})
    {:ok, leads}
  end

  def find_leads(search_term = @multiple_results_query, opts) do
    leads = load("find_multiple_leads.json")
    send(self(), {:closex_mock_client, :find_leads, [search_term, opts]})
    {:ok, leads}
  end

  def find_leads(search_term = @timeout_query, opts) do
    send(self(), {:closex_mock_client, :find_leads, [search_term, opts]})
    {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  end

  def find_leads(search_term, opts) do
    custom_filename = "find_lead_#{String.replace(search_term, " ", "_")}.json"
    leads = load(custom_filename, "find_one_lead.json")

    send(self(), {:closex_mock_client, :find_leads, [search_term, opts]})
    {:ok, leads}
  end

  @doc """
  Finds an opportunity in CloseIO.

  Returns `{:ok, opportunities}`.

  You can hand in any search term you like and it will return an example search which finds one example lead.

  You can also search for something you are not expecting to find with our not_found_id. This will provide the empty
  result set in find_no_opportunities.json.

  We have provided an example search term to use when the search term doesn't matter to you.

  ## Examples

    > Closex.MockClient.find_opportunities("foo")
    ...contents of test/fixtures/find_one_opportunity.json...

    iex> Closex.MockClient.find_opportunities(Closex.MockClient.not_found_query())
    {:ok, %{"data" => [], "has_more" => false, "total_results" => 0}}

    > Closex.MockClient.find_opportunities(Closex.MockClient.multiple_results_query())
    ...contents of test/fixtures/find_multiple_opportunities.json...
  """
  def find_opportunities(search_term, opts \\ [])

  def find_opportunities(search_term = @not_found_query, opts) do
    opportunities = load("find_no_opportunities.json")
    send(self(), {:closex_mock_client, :find_opportunities, [search_term, opts]})
    {:ok, opportunities}
  end

  def find_opportunities(search_term = @multiple_results_query, opts) do
    opportunities = load("find_multiple_opportunities.json")
    send(self(), {:closex_mock_client, :find_opportunities, [search_term, opts]})
    {:ok, opportunities}
  end

  def find_opportunities(search_term, opts) do
    opportunities = load("find_one_opportunity.json")
    send(self(), {:closex_mock_client, :find_opportunities, [search_term, opts]})
    {:ok, opportunities}
  end

  defp load(filename, fallback \\ nil) do
    case Application.fetch_env(:closex, :mock_client_fixtures_dir) do
      {:ok, fixtures_path} ->
        file =
          [fixtures_path, filename]
          |> Path.join()
          |> File.read()

        case file do
          {:ok, binary} ->
            Jason.decode!(binary)

          {:error, _} when fallback |> is_nil ->
            load_default(filename)

          {:error, _} ->
            load(fallback)
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
    |> Jason.decode!()
  end
end
