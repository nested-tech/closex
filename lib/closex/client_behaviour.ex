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
  @type search_term :: String.t()
  @type limit :: Integer.t()

  # Leads
  @callback find_leads(search_term) :: result
  @callback find_leads(search_term, opts) :: result

  @callback get_lead(id) :: result
  @callback get_lead(id, opts) :: result

  @callback create_lead(map) :: result
  @callback create_lead(map, opts) :: result

  @callback update_lead(id, map) :: result
  @callback update_lead(id, map, opts) :: result

  # Opportunities
  @callback find_opportunities(search_term) :: result
  @callback find_opportunities(search_term, opts) :: result

  @callback get_opportunity(id) :: result
  @callback get_opportunity(id, opts) :: result

  @callback get_opportunities() :: result
  @callback get_opportunities(opts) :: result

  @callback create_opportunity(map) :: result
  @callback create_opportunity(map, opts) :: result

  @callback update_opportunity(id, map) :: result
  @callback update_opportunity(id, map, opts) :: result

  # Custom field
  @callback get_lead_custom_field(id) :: result
  @callback get_lead_custom_field(id, opts) :: result

  # Organisation
  @callback get_organization(id) :: result
  @callback get_organization(id, opts) :: result

  # Statuses
  @callback get_lead_statuses() :: result
  @callback get_lead_statuses(opts) :: result

  @callback get_opportunity_statuses() :: result
  @callback get_opportunity_statuses(opts) :: result

  # Emails
  @callback send_email(map) :: result
  @callback send_email(map, opts) :: result

  # Notes
  @callback create_note(map) :: result
  @callback create_note(map, opts) :: result

  # Users
  @callback get_users() :: result
  @callback get_users(limit) :: result

  # Misc
  @callback find_all_opportunities(search_term) :: result
  @callback find_all_opportunities(search_term, limit) :: result

  @callback get_contact(id) :: result
  @callback get_contact(id, opts) :: result

  @callback create_contact(map) :: result
  @callback create_contact(map, opts) :: result

  @callback update_contact(id, map) :: result
  @callback update_contact(id, map, opts) :: result

  @callback merge_leads(id, id) :: result
  @callback merge_leads(id, id, opts) :: result

  @callback log_call(map) :: result
  @callback log_call(map, opts) :: result

  @callback find_phone_numbers(search_term) :: result
  @callback find_phone_numbers(search_term, opts) :: result

  @callback create_sms_activity(map) :: result
  @callback create_sms_activity(map, opts) :: result

  @callback create_email_activity(map) :: result
  @callback create_email_activity(map, opts) :: result

  @callback find_call_activities(search_term) :: result
  @callback find_activities(search_term) :: result

  @callback create_task(id, String.t()) :: result
  @callback create_task(id, String.t(), map) :: result
  @callback create_task(id, String.t(), map, opts) :: result

  @callback update_task(id) :: result
  @callback update_task(id, map) :: result
  @callback update_task(id, map, opts) :: result
end
