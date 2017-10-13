defmodule Closex.CachingClient do
  @behaviour Closex.ClientBehaviour
  @fallback_client Application.get_env(:closex, :fallback_client, Closex.HTTPClient)

  defdelegate find_leads(search_term, opts \\ []), to: @fallback_client

  def get_lead(lead_id, opts \\ []) do
    get_cached(lead_id, {@fallback_client, :get_lead, [lead_id, opts]})
  end

  defdelegate create_lead(payload, opts \\ []), to: @fallback_client
  defdelegate update_lead(lead_id, payload, opts \\ []), to: @fallback_client

  def get_opportunity(opportunity_id, opts \\ []) do
    get_cached(opportunity_id, {@fallback_client, :get_opportunity, [opportunity_id, opts]})
  end

  defdelegate create_opportunity(payload, opts \\ []), to: @fallback_client
  defdelegate update_opportunity(opportunity_id, payload, opts \\ []), to: @fallback_client

  defdelegate get_lead_custom_field(custom_field_id, opts \\ []), to: @fallback_client

  defdelegate get_organization(organization_id, opts \\ []), to: @fallback_client

  defdelegate get_lead_statuses(opts \\ []), to: @fallback_client

  defdelegate get_opportunity_statuses(opts \\ []), to: @fallback_client

  defdelegate send_email(payload, opts \\ []), to: @fallback_client

  defdelegate get_users(opts \\ []), to: @fallback_client

  defp get_cached(key, {mod, fun, args}) do
    Cachex.get(:closex_cache, key, fallback: fn key ->
      case apply(mod, fun, args) do
        success = {:ok, _} ->
          {:commit, success}
        error = {:error, _} ->
          {:ignore, error}
      end
    end)
  end
end
