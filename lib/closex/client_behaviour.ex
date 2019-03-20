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
  @callback get_opportunities(opts) :: result
  @callback create_opportunity(map, opts) :: result
  @callback update_opportunity(id, map, opts) :: result
  @callback create_task(id, String.t(), map, opts) :: result
  @callback update_task(id, map) :: result
  @callback get_lead_custom_field(id, opts) :: result
  @callback get_organization(id, opts) :: result
  @callback get_lead_statuses(opts) :: result
  @callback get_opportunity_statuses(opts) :: result
  @callback send_email(map, opts) :: result
  @callback get_users(opts) :: result
  @callback find_all_opportunities(String.t(), Integer.t()) :: result
  @callback create_contact(map, opts) :: result
  @callback update_contact(id, map, opts) :: result
  @callback merge_leads(id, id) :: result
  @callback log_call(map, opts) :: result
  @callback find_phone_numbers(String.t(), opts) :: result
  @callback create_sms_activity(map, opts) :: result
  @callback create_sms_activity(map) :: result
  @callback find_call_activies(String.t()) :: result
end
