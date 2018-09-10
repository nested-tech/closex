defmodule Closex.ClientBehaviour do
  @moduledoc """
  Tools for interacting with the Close.io API

  TODO: Add more docs
  """

  @type id :: String.t()
  @type opts :: Keyword.t()
  @type success :: {:ok, map}
  @type error :: {:error, any}
  @type result :: success | error

  @callback find_leads(String.t(), opts) :: result
  @callback find_opportunities(String.t(), opts) :: result
  @callback get_lead(id, opts) :: result
  @callback create_lead(map, opts) :: result
  @callback update_lead(id, map, opts) :: result
  @callback get_opportunity(id, opts) :: result
  @callback create_opportunity(map, opts) :: result
  @callback update_opportunity(id, map, opts) :: result
  @callback get_lead_custom_field(id, opts) :: result
  @callback get_organization(id, opts) :: result
  @callback get_lead_statuses(opts) :: result
  @callback get_opportunity_statuses(opts) :: result
  @callback send_email(map, opts) :: result
  @callback get_users(opts) :: result
  @callback get_opportunities(opts) :: result
end
