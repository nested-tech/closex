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
    opts = merge_search_term_into_opts(search_term, opts)

    # HACK: Pass empty object as body to workaround bug in HTTPoison, see: https://github.com/edgurgel/httpoison/issues/285
    request(:get, "/lead/", %{}, [{"Content-Type", "application/json"}], opts)
    |> handle_response
  end

  @doc "List or search for opportunities: https://developer.close.io/#opportunities-list-or-filter-opportunities"
  def find_opportunities(search_term, opts \\ []) do
    opts = merge_search_term_into_opts(search_term, opts)

    # HACK: Pass empty object as body to workaround bug in HTTPoison, see: https://github.com/edgurgel/httpoison/issues/285
    request(:get, "/opportunity/", %{}, [{"Content-Type", "application/json"}], opts)
    |> handle_response
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

  @doc "Fetch a single lead: https://developer.close.io/#leads-retrieve-a-single-lead"
  def get_lead(lead_id, opts \\ []), do: fetch_object("lead", lead_id, opts)

  @doc "Create a new lead: https://developer.close.io/#leads-create-a-new-lead"
  def create_lead(payload, opts \\ []), do: create_object("lead", payload, opts)

  @doc "Update an existing lead: https://developer.close.io/#leads-update-an-existing-lead"
  def update_lead(lead_id, payload, opts \\ []), do: update_object("lead", lead_id, payload, opts)

  @doc "Fetch a single opportunity: https://developer.close.io/#opportunities-retrieve-an-opportunity"
  def get_opportunity(opportunity_id, opts \\ []), do: fetch_object("opportunity", opportunity_id, opts)

  @doc "Create an opportunity: https://developer.close.io/#opportunities-create-an-opportunity"
  def create_opportunity(payload, opts \\ []), do: create_object("opportunity", payload, opts)

  @doc "Update an opportunity: https://developer.close.io/#opportunities-update-an-opportunity"
  def update_opportunity(opportunity_id, payload, opts \\ []), do: update_object("opportunity", opportunity_id, payload, opts)

  # Lead Custom Fields

  @doc "Fetch a custom fields details: https://developer.close.io/#custom-fields-fetch-custom-fields-details"
  def get_lead_custom_field(custom_field_id, opts \\ []), do: fetch_object("custom_fields/lead", custom_field_id, opts)

  # Organization

  @doc """
  Get an organizations details: https://developer.close.io/#organizations-get-an-organizations-details-including-its-current-members

  NOTE: Use American spelling of "organization" since this is how Close.IO refers to it.
  """
  def get_organization(organization_id, opts \\ []), do: fetch_object("organization", organization_id, opts)

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
    post("/activity/email/", payload, [{"Content-Type", "application/json"}], opts)
    |> handle_response
  end

  # Users

  # TODO: at some point we'll need to build a generic pagination/fetch more routine when we hit 50+ users
  @doc "List all users in your organization: https://developer.close.io/#users-list-all-the-users-who-are-members-of-the-same-organizations-as-you-are"
  def get_users(opts \\ []) do
    request(:get, "/user/", %{}, [{"Content-Type", "application/json"}], opts) |> handle_response
  end

  # Private stuff...

  defp handle_response({:ok, %{status_code: _, body: %{"error" => reason}}}) do
    {:error, reason}
  end
  defp handle_response({:ok, %{status_code: 400, body: reason = %{"errors" => _errors, "field-errors" => _field_errors}}}) do
    {:error, reason}
  end
  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, body}
  end
  defp handle_response({:error, reason}) do
    {:error, reason}
  end

  defp fetch_object(obj_type, obj_id, opts) do
    # HACK: Workaround bug in HTTPoison, see: https://github.com/edgurgel/httpoison/issues/285
    request(:get, "/#{obj_type}/#{obj_id}/", %{}, [{"Content-Type", "application/json"}], opts)
    |> handle_response
  end

  defp update_object(object_type, object_id, payload, opts) do
    put("/#{object_type}/#{object_id}/", payload, [{"Content-Type", "application/json"}], opts)
    |> handle_response
  end

  defp create_object(object_type, payload, opts) do
    post("/#{object_type}/", payload, [{"Content-Type", "application/json"}], opts)
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

  defp process_request_body(body) do
    Poison.encode!(body)
  end

  # Attempt to parse the body into JSON but in case that fails, pass the
  # original body through untouched
  defp process_response_body(body) do
    case Poison.decode(body) do
      {:ok, body} -> body
      {:error, _} -> body
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
