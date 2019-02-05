defmodule Closex.HTTPClient do
  use HTTPoison.Base

  @moduledoc """
  A client wrapper around the Close.IO HTTP API.

  See: https://developer.close.io/
  """

  @base_url "https://app.close.io/api/v1"
  @behaviour Closex.ClientBehaviour
  @sleep_module Application.get_env(:closex, :sleep_module, Process)

  ## TODO: httpoison opts should move underneath the `:httpoison` key

  @doc "List or search for leads: https://developer.close.io/#leads-list-or-search-for-leads"
  @impl true
  def find_leads(search_term, opts \\ []) do
    find("lead", search_term, opts)
  end

  @doc "List or search for opportunities: https://developer.close.io/#opportunities-list-or-filter-opportunities"
  @impl true
  def find_opportunities(search_term, opts \\ []) do
    find("opportunity", search_term, opts)
  end

  @doc "Fetch a single lead: https://developer.close.io/#leads-retrieve-a-single-lead"
  @impl true
  def get_lead(lead_id, opts \\ []), do: fetch_object("lead", lead_id, opts)

  @doc "Create a new lead: https://developer.close.io/#leads-create-a-new-lead"
  @impl true
  def create_lead(payload, opts \\ []), do: create_object("lead", payload, opts)

  @doc "Update an existing lead: https://developer.close.io/#leads-update-an-existing-lead"
  @impl true
  def update_lead(lead_id, payload, opts \\ []), do: update_object("lead", lead_id, payload, opts)

  @doc "Fetch a single opportunity: https://developer.close.io/#opportunities-retrieve-an-opportunity"
  @impl true
  def get_opportunity(opportunity_id, opts \\ []),
    do: fetch_object("opportunity", opportunity_id, opts)

  @doc "Get opportunities: https://developer.close.io/#opportunities"
  @impl true
  def get_opportunities(opts \\ []) do
    get("/opportunity/", [], opts)
    |> handle_response
  end

  @doc "Create an opportunity: https://developer.close.io/#opportunities-create-an-opportunity"
  @impl true
  def create_opportunity(payload, opts \\ []), do: create_object("opportunity", payload, opts)

  @doc "Update an opportunity: https://developer.close.io/#opportunities-update-an-opportunity"
  @impl true
  def update_opportunity(opportunity_id, payload, opts \\ []),
    do: update_object("opportunity", opportunity_id, payload, opts)

  # Lead Custom Fields

  @doc "Fetch a custom fields details: https://developer.close.io/#custom-fields-fetch-custom-fields-details"
  @impl true
  def get_lead_custom_field(custom_field_id, opts \\ []),
    do: fetch_object("custom_fields/lead", custom_field_id, opts)

  # Organization

  @doc """
  Get an organizations details: https://developer.close.io/#organizations-get-an-organizations-details-including-its-current-members

  NOTE: Use American spelling of "organization" since this is how Close.IO refers to it.
  """
  @impl true
  def get_organization(organization_id, opts \\ []),
    do: fetch_object("organization", organization_id, opts)

  # Statuses

  # TODO: rename this function - as it's a list operation it feels odd calling it GET in the same sense as the singular getters.
  @doc "List lead statuses for your organization: https://developer.close.io/#lead-statuses-list-lead-statuses-for-your-organization"
  @impl true
  def get_lead_statuses(opts \\ []), do: fetch_object("status", "lead", opts)

  # TODO: rename this function - as it's a list operation it feels odd calling it GET in the same sense as the singular getters.
  @doc "List opportunity statuses for your organization: https://developer.close.io/#opportunity-statuses-list-opportunity-statuses-for-your-organization"
  @impl true
  def get_opportunity_statuses(opts \\ []), do: fetch_object("status", "opportunity", opts)

  # Emails

  @doc "Create an email activity: https://developer.close.io/#activities-create-an-email-activity"
  @impl true
  def send_email(payload, opts \\ []) do
    post_json("/activity/email/", payload, [], opts)
    |> handle_response
  end

  # Users

  @doc "List all users in your organization: https://developer.close.io/#users-list-all-the-users-who-are-members-of-the-same-organizations-as-you-are"
  @impl true
  def get_users(limit \\ 100) do
    find_all("user", "", limit)
  end

  @impl true
  def find_all_opportunities(term, limit \\ 100) do
    find_all("opportunity", term, limit)
  end

  @impl true
  def create_contact(payload, opts \\ []) do
    post_json("/contact/", payload, [], opts)
    |> handle_response
  end

  @impl true
  def update_contact(contact_id, payload, opts \\ []) do
    put_json("/contact/#{contact_id}/", payload, [], opts)
    |> handle_response
  end

  @impl true
  def merge_leads(source_lead_id, destination_lead_id, opts \\ []) do
    post_json(
      "/lead/merge/",
      %{"source" => source_lead_id, "destination" => destination_lead_id},
      [],
      opts
    )
    |> handle_response
  end

  @doc "Log a call activity manually:
  https://developer.close.io/#activities-log-a-call-activity-manually"
  @impl true
  def log_call(payload, opts \\ []) do
    post_json("/activity/call/", payload, [], opts)
    |> handle_response
  end

  @doc "list or search for phone numbers:
  https://developer.close.io/#phone-numbers"
  @impl true
  def find_phone_numbers(search_term, opts \\ []) do
    # We call make_find_request directly because the search term IS the query string for this request
    # i.e. ?number=1234 and not ?query="number=1234"
    make_find_request("phone_number/?#{search_term}", opts)
  end

  @doc "Create an sms activity in close.io:
  https://developer.close.io/#activities-create-an-sms-activity"
  @impl true
  def create_sms_activity(payload, opts \\ []) do
    post_json("/activity/sms/", payload, [], opts)
    |> handle_response
  end

  # Private stuff...

  defp find(resource, search_term, opts) do
    opts = merge_search_term_into_opts(search_term, opts)

    if rate_limit_retry?(opts) do
      find_respecting_rate_limit(resource, opts)
    else
      make_find_request(resource, opts)
    end
  end

  defp make_find_request(resource, opts) do
    get("/#{resource}/", [], opts)
    |> handle_response
  end

  # This function will attempt to carry out a `find` operation. If that fails
  # with a 429 (Too Many Requests), close.io will provide us rate limiting
  # information. Use this to wait till the end of the reset window and retry.
  # See https://developer.close.io/#ratelimits for more info
  #
  defp find_respecting_rate_limit(resource, opts) do
    response = make_find_request(resource, opts)

    case response do
      {:error, %{status_code: 429, body: %{"rate_reset" => rate_reset}}} ->
        wait_and_retry(resource, opts, rate_reset)

      no_rate_limit ->
        no_rate_limit
    end
  end

  defp wait_and_retry(resource, opts, rate_reset) do
    {seconds, _remainder} = Integer.parse(rate_reset)

    @sleep_module.sleep(:timer.seconds(seconds + 1))

    make_find_request(resource, opts)
  end

  def find_all(resource, search, limit \\ 100, skip \\ 0, results \\ []) do
    case find(resource, search, params: %{_limit: limit, _skip: skip}) do
      {:ok, response} ->
        accumulated_data = results ++ response["data"]

        if response["has_more"] do
          find_all(resource, search, limit, skip + limit, accumulated_data)
        else
          {:ok, Map.put(response, "data", accumulated_data)}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @impl true
  @doc "Creates a task for the given lead and text. [Optional parameters](https://developer.close.io/#tasks-create-a-task)"
  def create_task(lead_id, text, params \\ %{}, opts \\ []) do
    payload = Map.merge(params, %{lead_id: lead_id, text: text})
    create_object("task", payload, opts)
  end

  @impl true
  @doc "Updates a task. [Optional parameters](https://developer.close.io/#tasks-update-a-task)"
  def update_task(task_id, params \\ %{}, opts \\ []) do
    update_object("task", task_id, params, opts)
  end

  defp merge_search_term_into_opts(search_term, opts) do
    search_params = %{query: search_term}

    case Keyword.get(opts, :params) do
      params when is_map(params) ->
        all_params = Map.merge(params, search_params)
        Keyword.put(opts, :params, all_params)

      nil ->
        Keyword.put(opts, :params, search_params)
    end
  end

  defp handle_response({:ok, %{status_code: _, body: %{"error" => reason}}}) do
    {:error, reason}
  end

  defp handle_response(
         {:ok,
          %{
            status_code: 400,
            body: reason
          }}
       ) do
    {:error, reason}
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response({:ok, response = %{status_code: status_code}}) when status_code >= 500 do
    {:error, response}
  end

  defp handle_response({:ok, response = %{status_code: 429}}) do
    {:error, response}
  end

  defp handle_response({:error, response}) do
    {:error, response}
  end

  defp fetch_object(obj_type, obj_id, opts) do
    get("/#{obj_type}/#{obj_id}/", [], opts)
    |> handle_response
  end

  defp update_object(object_type, object_id, payload, opts) do
    put_json(
      "/#{object_type}/#{object_id}/",
      payload,
      [],
      opts
    )
    |> handle_response
  end

  defp create_object(object_type, payload, opts) do
    post_json("/#{object_type}/", payload, [], opts)
    |> handle_response
  end

  @impl true
  def process_request_headers(headers) do
    headers
    |> add_header({"Accept", "application/json"})
    |> add_header({"Content-Type", "application/json"})
  end

  defp add_header(headers, tuple = {name, _value}) do
    case :proplists.get_value(name, headers) do
      :undefined -> [tuple | headers]
      _ -> headers
    end
  end

  @impl true
  def process_request_options(options) do
    default_opts = [
      hackney: [basic_auth: {api_key(), ""}]
    ]

    Keyword.merge(default_opts, options)
  end

  defp put_json(path, payload, headers, opts) do
    put(path, Jason.encode!(payload), headers, opts)
  end

  defp post_json(path, payload, headers, opts) do
    post(path, Jason.encode!(payload), headers, opts)
  end

  # Attempt to parse the body into JSON but in case that fails, pass the
  # original body through untouched
  @impl true
  def process_response_body(body) do
    case Jason.decode(body) do
      {:ok, body} -> body
      {:error, _} -> body
      {:error, :invalid, _} -> body
    end
  end

  @impl true
  def process_url(path) do
    @base_url <> path
  end

  defp api_key do
    case Application.fetch_env!(:closex, :api_key) do
      {:system, env} -> System.get_env(env)
      key when is_binary(key) -> key
    end
  end

  defp rate_limit_retry?(opts) do
    Keyword.get(
      opts,
      :rate_limit_retry,
      Application.get_env(:closex, :rate_limit_retry, false)
    )
  end
end
