defmodule Closex.CachingClient do
  @behaviour Closex.ClientBehaviour

  @moduledoc """
  Provides a cache wrapper around calls made to close.io

  The cache layer itself has been abstracted away in order to allow us to experiment with and support different caching strategies.
  """

  defdelegate find_leads(search_term, opts \\ []), to: Closex.fallback_client

  def get_lead(lead_id, opts \\ []) do
    Closex.cache.get(lead_id, {:get_lead, [lead_id, opts]})
  end

  defdelegate create_lead(payload, opts \\ []), to: Closex.fallback_client

  def update_lead(lead_id, payload, opts \\ []) do
    case apply(Closex.fallback_client, :update_lead, [lead_id, payload, opts]) do
      {:ok, updated_lead} -> {:ok, Closex.cache.set(lead_id, updated_lead)}
      {:error, reason} -> {:error, reason}
    end
  end

  def get_opportunity(opportunity_id, opts \\ []) do
    Closex.cache.get(opportunity_id, {:get_opportunity, [opportunity_id, opts]})
  end

  defdelegate create_opportunity(payload, opts \\ []), to: Closex.fallback_client

  def update_opportunity(opportunity_id, payload, opts \\ []) do
    case apply(Closex.fallback_client, :update_opportunity, [opportunity_id, payload, opts]) do
      {:ok, updated_opportunity} -> {:ok, Closex.cache.set(opportunity_id, updated_opportunity)}
      {:error, reason} -> {:error, reason}
    end
  end

  def get_lead_custom_field(custom_field_id, opts \\ []) do
    Closex.cache.get(custom_field_id, {:get_lead_custom_field, [custom_field_id, opts]})
  end

  def get_organization(organization_id, opts \\ []) do
    Closex.cache.get(organization_id, {:get_organization, [organization_id, opts]})
  end

  def get_lead_statuses(opts \\ []) do
    Closex.cache.get(:get_lead_statuses, {:get_lead_statuses, [opts]})
  end

  def get_opportunity_statuses(opts \\ []) do
    Closex.cache.get(:get_opportunity_statuses, {:get_opportunity_statuses, [opts]})
  end

  defdelegate send_email(payload, opts \\ []), to: Closex.fallback_client

  def get_users(opts \\ []) do
    Closex.cache.get(:get_users, {:get_users, [opts]})
  end
end
