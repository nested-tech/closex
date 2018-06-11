defmodule Closex.HTTPClient do
  use HTTPoison.Base

  @moduledoc """
  A client wrapper around the Close.IO HTTP API.

  See: https://developer.close.io/
  """

  @base_url "https://app.close.io/api/v1"
  @behaviour Closex.ClientBehaviour

  ## TODO: httpoison opts should move underneath the `:httpoison` key

  @doc "List or search for leads: https://developer.close.io/#leads-list-or-search-for-leads"
  def find_leads(search_term, opts \\ []) do
    find_respecting_rate_limit("lead", search_term, opts)
  end

  @doc "List or search for opportunities: https://developer.close.io/#opportunities-list-or-filter-opportunities"
  def find_opportunities(search_term, opts \\ []) do
    find_respecting_rate_limit("opportunity", search_term, opts)
  end

  @doc "Fetch a single lead: https://developer.close.io/#leads-retrieve-a-single-lead"
  def get_lead(lead_id, opts \\ []), do: fetch_object("lead", lead_id, opts)

  @doc "Create a new lead: https://developer.close.io/#leads-create-a-new-lead"
  def create_lead(payload, opts \\ []), do: create_object("lead", payload, opts)

  @doc "Update an existing lead: https://developer.close.io/#leads-update-an-existing-lead"
  def update_lead(lead_id, payload, opts \\ []), do: update_object("lead", lead_id, payload, opts)

  @doc "Fetch a single opportunity: https://developer.close.io/#opportunities-retrieve-an-opportunity"
  def get_opportunity(opportunity_id, opts \\ []),
    do: fetch_object("opportunity", opportunity_id, opts)

  @doc "Create an opportunity: https://developer.close.io/#opportunities-create-an-opportunity"
  def create_opportunity(payload, opts \\ []), do: create_object("opportunity", payload, opts)

  @doc "Update an opportunity: https://developer.close.io/#opportunities-update-an-opportunity"
  def update_opportunity(opportunity_id, payload, opts \\ []),
    do: update_object("opportunity", opportunity_id, payload, opts)

  # Lead Custom Fields

  @doc "Fetch a custom fields details: https://developer.close.io/#custom-fields-fetch-custom-fields-details"
  def get_lead_custom_field(custom_field_id, opts \\ []),
    do: fetch_object("custom_fields/lead", custom_field_id, opts)

  # Organization

  @doc """
  Get an organizations details: https://developer.close.io/#organizations-get-an-organizations-details-including-its-current-members

  NOTE: Use American spelling of "organization" since this is how Close.IO refers to it.
  """
  def get_organization(organization_id, opts \\ []),
    do: fetch_object("organization", organization_id, opts)

  # Statuses

  # TODO: rename this function - as it's a list operation it feels odd calling it GET in the same sense as the singular getters.
  @doc "List lead statuses for your organization: https://developer.close.io/#lead-statuses-list-lead-statuses-for-your-organization"
  def get_lead_statuses(opts \\ []), do: fetch_object("status", "lead", opts)

  # TODO: rename this function - as it's a list operation it feels odd calling it GET in the same sense as the singular getters.
  @doc "List opportunity statuses for your organization: https://developer.close.io/#opportunity-statuses-list-opportunity-statuses-for-your-organization"
  def get_opportunity_statuses(opts \\ []), do: fetch_object("status", "opportunity", opts)

  # Emails

  @doc "Create an email activity: https://developer.close.io/#activities-create-an-email-activity"
  def send_email(payload, opts \\ []) do
    post_json("/activity/email/", payload, [{"Content-Type", "application/json"}], opts)
    |> handle_response
  end

  # Users

  @doc "List all users in your organization: https://developer.close.io/#users-list-all-the-users-who-are-members-of-the-same-organizations-as-you-are"
  def get_users(limit \\ 100) do
    find_all("user", "", limit)
  end

  def find_all_opportunities(term, limit \\ 100) do
    find_all("opportunity", term, limit)
  end

  # Private stuff...

  defp find(resource, opts) do
    get("/#{resource}/", [], opts)
    |> handle_response
  end

  # This function will attempt to carry out a `find` operation. If that fails
  # with a 429 (Too Many Requests), close.io will provide us rate limiting
  # information. Use this to wait till the end of the reset window and retry.
  # See https://developer.close.io/#ratelimits for more info
  #
  # REVIEW: I've only implemented this on `find` as that's the only place we're
  # hitting rate limits and it limits the scope of this change (in case of
  # fubar). Should this be applied more generally?
  defp find_respecting_rate_limit(resource, search_term, opts) do
    opts = merge_search_term_into_opts(search_term, opts)

    response = find(resource, opts)

    case response do
      {:error, %{status_code: 429, body: %{"rate_reset" => rate_reset}}} ->
        wait_and_retry(resource, opts, rate_reset)

      no_rate_limit ->
        no_rate_limit
    end
  end

  defp wait_and_retry(resource, opts, rate_reset) do
    {seconds, _remainder} = Integer.parse(rate_reset)

    if Mix.env() != :test, do: Process.sleep(:timer.seconds(seconds + 1))

    # REVIEW: This is purely for tests, is that a smell? Any alternatives?
    send(self(), {:retry_find, [seconds + 1]})

    find(resource, opts)
  end

  def find_all(resource, search, limit \\ 100, skip \\ 0, results \\ []) do
    {:ok, response} =
      find_respecting_rate_limit(resource, search, params: %{_limit: limit, _skip: skip})

    accumulated_data = results ++ response["data"]

    if response["has_more"] do
      find_all(resource, search, limit, skip + limit, accumulated_data)
    else
      {:ok, Map.put(response, "data", accumulated_data)}
    end
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
            body: reason = %{"errors" => _errors, "field-errors" => _field_errors}
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
      [{"Content-Type", "application/json"}],
      opts
    )
    |> handle_response
  end

  defp create_object(object_type, payload, opts) do
    post_json("/#{object_type}/", payload, [{"Content-Type", "application/json"}], opts)
    |> handle_response
  end

  defp process_request_headers(headers) do
    case :proplists.get_value("Accept", headers) do
      :undefined -> [{"Accept", "application/json"} | headers]
      _ -> headers
    end
  end

  defp process_request_options(options) do
    default_opts = [
      hackney: [basic_auth: {api_key(), ""}]
    ]

    Keyword.merge(default_opts, options)
  end

  defp put_json(path, payload, headers, opts) do
    put(path, Poison.encode!(payload), headers, opts)
  end

  defp post_json(path, payload, headers, opts) do
    post(path, Poison.encode!(payload), headers, opts)
  end

  # Attempt to parse the body into JSON but in case that fails, pass the
  # original body through untouched
  defp process_response_body(body) do
    case Poison.decode(body) do
      {:ok, body} -> body
      {:error, _} -> body
      {:error, :invalid, _} -> body
    end
  end

  defp process_url(path) do
    @base_url <> path
  end

  defp api_key do
    case Application.fetch_env!(:closex, :api_key) do
      {:system, env} -> System.get_env(env)
      key when is_binary(key) -> key
    end
  end
end
