defmodule Closex.HTTPClientTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
    ExVCR.Config.cassette_library_dir "test/fixtures/vcr_cassettes"
  end
  import Closex.HTTPClient

  @valid_lead_id "lead_ibiNeZe7yE0ZoJZQUKm0Eymg0nxDH2xb5fHg8IzBsAm"
  @invalid_lead_id "wibble"
  @valid_opportunity_id "oppo_FgrpAmjn3038nP03AtkSYza3DVn2ZoUWk682Px55L5o"
  @invalid_opportunity_id "wobble"
  @valid_custom_field_id "lcf_8cL4GPyF0uTbp9c87c2kBTvHO8Wnnv8c8bw0RqMgrZU"
  @invalid_custom_field_id "quux"
  @potential_status_id "stat_dzhTAsvOFDm6CbgRQkPjdjAeO6B8lFCeZcuDwN2yjFd"
  @invalid_status_id "foo"
  @valid_create_lead_params %{
                              "name" => "Bluth Company",
                              "url" => "http://thebluthcompany.tumblr.com/",
                              "description" => "Best. Show. Ever.",
                              "status_id" => @potential_status_id,
                              "contacts" => [%{
                                 "name" => "Gob",
                                 "title" => "Sr. Vice President",
                                 "emails" => [%{
                                    "type" => "office",
                                    "email" => "gob@example.com",
                                  }],
                                 "phones" => [%{
                                    "type" => "office",
                                    "phone" => "8004445555",
                                  }],
                               }],
                              "custom.lcf_RKxL7ypo8Nrqrf5mBX5XQT1502TCIuQXEb2p0w4QvoV" => "Website contact form",
                              "custom.lcf_Sr9rVrGnpmRGSS5tSPSqYNcVVIh1JsSU26U30oE6b7y" => "Segway",
                              "custom.lcf_uisJjG9EUCD8WpsmEPNFQw6gpB8cxlrf6QEGrmcsqbn" => "Real Estate",
                              "addresses" => [%{
                                 "label" => "business",
                                 "address_1" => "747 Howard St",
                                 "address_2" => "Room 3",
                                 "city" => "San Francisco",
                                 "state" => "CA",
                                 "zipcode" => "94103",
                                 "country" => "US",
                               }],
                            }
  @invalid_create_lead_params %{"status_id" => @invalid_status_id}
  @active_opportunity_status_id "stat_vQWQtofUTvlcdgo1R1lsauc5Inez29fxk0SEOKC8qBg"
  @valid_opportunity_create_params %{
                                     "note" => "i hope this deal closes...",
                                     "confidence" => 90,
                                     "lead_id" => @valid_lead_id,
                                     "status_id" => @active_opportunity_status_id,
                                     "value" => 500,
                                     "value_period" => "monthly",
                                   }
  @created_opportunity_id "oppo_otkBudcuHXq90sC43gex0ddp5XYQjvKndlOGMHjE9Ph"
  @invalid_opportunity_create_params %{}
  @intro_email_template_id "tmpl_8Mykq86upeoxJGZPkc0debiBLzcjQ5NJnRUo9UJRCMW"
  @gob_bluth_contact_id "cont_CyVw29BYxNQl4bF1FuT04VTjKRtPsHQB1oLMWxFFBLJ"
  @organization_id "orga_CC25dsMNG4KsRpxn2LEwPUVyGRs4poLYFIBsioIK4Oj"

  describe "get_lead/1" do
    test "when close.io is up and we are passed a valid lead_id, it returns the lead" do
      use_cassette "get_lead" do
        {:ok, lead} = get_lead(@valid_lead_id)
        assert Map.keys(lead) ==
                 ["addresses",
                  "contacts",
                  "created_by",
                  "created_by_name",
                  "custom",
                  "custom.lcf_RKxL7ypo8Nrqrf5mBX5XQT1502TCIuQXEb2p0w4QvoV",
                  "custom.lcf_Sr9rVrGnpmRGSS5tSPSqYNcVVIh1JsSU26U30oE6b7y",
                  "custom.lcf_uisJjG9EUCD8WpsmEPNFQw6gpB8cxlrf6QEGrmcsqbn",
                  "date_created",
                  "date_updated",
                  "description",
                  "display_name",
                  "html_url",
                  "id",
                  "integration_links",
                  "name",
                  "opportunities",
                  "organization_id",
                  "status_id",
                  "status_label",
                  "tasks",
                  "updated_by",
                  "updated_by_name",
                  "url"]
        assert lead["id"] == @valid_lead_id
        assert lead["name"] == "Luke Skywalker"
      end
    end
    test "when close.io is up, but the lead_id passed is invalid, it fails" do
      use_cassette "get_lead_unknown" do
        {:error, reason} = get_lead(@invalid_lead_id)
        assert reason == "Empty query: Lead matching query does not exist."
      end
    end

    test "with invalid key" do
      use_cassette "get_lead_invalid_key" do
        {:error, reason} = get_lead(@valid_lead_id)
        assert reason == "The server could not verify that you are authorized to access the URL requested.  You either supplied the wrong credentials (e.g. a bad password), or your browser doesn't understand how to supply the credentials required."
      end
    end
  end
  describe "get_opportunity/1" do
    test "when close.io is up and we are passed a valid opportunity_id, it returns the opportunity" do
      use_cassette "get_opportunity" do
        {:ok, opportunity} = get_opportunity(@valid_opportunity_id)
        assert Map.keys(opportunity) ==
                 ["confidence",
                  "contact_id",
                  "contact_name",
                  "created_by",
                  "created_by_name",
                  "date_created",
                  "date_lost",
                  "date_updated",
                  "date_won",
                  "id",
                  "integration_links",
                  "lead_id",
                  "lead_name",
                  "note",
                  "organization_id",
                  "status_id",
                  "status_label",
                  "status_type",
                  "updated_by",
                  "updated_by_name",
                  "user_id",
                  "user_name",
                  "value",
                  "value_currency",
                  "value_formatted",
                  "value_period"]
        assert opportunity["id"] == @valid_opportunity_id
        assert opportunity["lead_id"] ==
                 "lead_A7hgScTsWRsrRFjvXkghP5mPkJBixfxcBJjgIDGkbuZ"
        assert opportunity["status_id"] ==
                 "stat_gc2L6rDDQV9evg1PbdEW0LvgtBrnu1EhMQUgJXZ6Kuy"
        assert opportunity["value"] == 20000
      end
    end
    test "when close.io is up, but the opportunity_id passed is invalid, it fails" do
      use_cassette "get_opportunity_unknown" do
        {:error, reason} = get_opportunity(@invalid_opportunity_id)
        assert reason ==
                 "Empty query: Opportunity matching query does not exist."
      end
    end
  end
  describe "get_lead_custom_field/1" do
    test "fetches and returns a lead custom field if it exists" do
      use_cassette "get_lead_custom_field" do
        {:ok, custom_field} = get_lead_custom_field(@valid_custom_field_id)
        assert custom_field ==
                 %{
                   "choices" => ["bar", "baz", "foo", "waa"],
                   "created_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                   "date_created" => "2017-08-31T15:42:56.925000+00:00",
                   "date_updated" => "2017-08-31T15:44:04.890000+00:00",
                   "id" => "lcf_8cL4GPyF0uTbp9c87c2kBTvHO8Wnnv8c8bw0RqMgrZU",
                   "name" => "Listing Reference",
                   "organization_id" => "orga_CC25dsMNG4KsRpxn2LEwPUVyGRs4poLYFIBsioIK4Oj",
                   "type" => "choices",
                   "updated_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                 }
      end
    end
    test "returns error if lead custom field does not exist" do
      use_cassette "get_lead_custom_field_unknown" do
        {:error, reason} = get_lead_custom_field(@invalid_custom_field_id)
        assert reason ==
                 "Empty query: LeadCustomField matching query does not exist."
      end
    end
  end
  describe "create_lead/1" do
    test "when close.io is up and we are passed a valid lead payload, creates a lead on CloseIO" do
      use_cassette "create_lead", match_requests_on: [:request_body] do
        {:ok, lead} = create_lead(@valid_create_lead_params)
        assert lead ==
                 %{
                   "addresses" => [%{
                      "address_1" => "747 Howard St",
                      "address_2" => "Room 3",
                      "city" => "San Francisco",
                      "country" => "US",
                      "label" => "business",
                      "state" => "CA",
                      "zipcode" => "94103",
                    }],
                   "contacts" => [%{
                      "created_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                      "date_created" => "2017-09-29T10:40:23.089000+00:00",
                      "date_updated" => "2017-09-29T10:40:23.089000+00:00",
                      "emails" => [%{
                         "email" => "gob@example.com",
                         "type" => "office",
                       }],
                      "id" => "cont_CyVw29BYxNQl4bF1FuT04VTjKRtPsHQB1oLMWxFFBLJ",
                      "integration_links" => [],
                      "lead_id" => "lead_ibiNeZe7yE0ZoJZQUKm0Eymg0nxDH2xb5fHg8IzBsAm",
                      "name" => "Gob",
                      "organization_id" => "orga_CC25dsMNG4KsRpxn2LEwPUVyGRs4poLYFIBsioIK4Oj",
                      "phones" => [%{
                         "phone" => "+448004445555",
                         "phone_formatted" => "+44 800 444 5555",
                         "type" => "office",
                       }],
                      "title" => "Sr. Vice President",
                      "updated_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                      "urls" => [],
                    }],
                   "created_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                   "created_by_name" => "API User (DO NOT DELETE)",
                   "custom" => %{
                     "Google Analytics ID" => "Website contact form",
                     "Mixpanel ID" => "Segway",
                     "Offer ID" => "Real Estate",
                   },
                   "custom.lcf_RKxL7ypo8Nrqrf5mBX5XQT1502TCIuQXEb2p0w4QvoV" => "Website contact form",
                   "custom.lcf_Sr9rVrGnpmRGSS5tSPSqYNcVVIh1JsSU26U30oE6b7y" => "Segway",
                   "custom.lcf_uisJjG9EUCD8WpsmEPNFQw6gpB8cxlrf6QEGrmcsqbn" => "Real Estate",
                   "date_created" => "2017-09-29T10:40:23.084000+00:00",
                   "date_updated" => "2017-09-29T10:40:23.140000+00:00",
                   "description" => "Best. Show. Ever.",
                   "display_name" => "Bluth Company",
                   "html_url" => "https://app.close.io/lead/lead_ibiNeZe7yE0ZoJZQUKm0Eymg0nxDH2xb5fHg8IzBsAm/",
                   "id" => "lead_ibiNeZe7yE0ZoJZQUKm0Eymg0nxDH2xb5fHg8IzBsAm",
                   "integration_links" => [],
                   "name" => "Bluth Company",
                   "opportunities" => [],
                   "organization_id" => "orga_CC25dsMNG4KsRpxn2LEwPUVyGRs4poLYFIBsioIK4Oj",
                   "status_id" => "stat_dzhTAsvOFDm6CbgRQkPjdjAeO6B8lFCeZcuDwN2yjFd",
                   "status_label" => "Potential",
                   "tasks" => [],
                   "updated_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                   "updated_by_name" => "API User (DO NOT DELETE)",
                   "url" => "http://thebluthcompany.tumblr.com/",
                 }
      end
    end
    test "when close.io is up and we are passed an invalid lead payload, renders error" do
      use_cassette "create_lead_error", match_requests_on: [:request_body] do
        {:error, reason} = create_lead(@invalid_create_lead_params)
        assert reason ==
                 %{
                   "errors" => [],
                   "field-errors" => %{
                     "status" => "Not a valid choice. Please go to Customizations in your organization settings and add \"foo\" to the list of lead statuses.",
                   },
                 }
      end
    end
  end
  describe "update_lead/2" do
    test "when close.io is up and we are passed a valid lead_id, it updates and returns the lead" do
      use_cassette "update_lead", match_requests_on: [:request_body] do
        lead_id = @valid_lead_id
        payload = %{"name" => "Luke Skywalker"}
        {:ok, lead_before} = get_lead(lead_id)
        {:ok, lead_after} = update_lead(lead_id, payload)
        assert lead_before != lead_after
        assert lead_before["name"] == "Bluth Company"
        assert lead_after["name"] == "Luke Skywalker"
      end
    end
    test "when close.io is up, but the lead_id passed is invalid, it fails" do
      use_cassette "update_lead_unknown" do
        {:error, reason} =
          update_lead(@invalid_lead_id, %{"name" => "Bob Fleming"})
        assert reason == "Empty query: Lead matching query does not exist."
      end
    end
  end
  describe "find_leads/1" do
    test "if some leads are found, it returns a list of leads" do
      search_term = "Minogue OR Princess"
      use_cassette "find_leads" do
        {:ok, result} = find_leads(search_term)
        assert %{"has_more" => false, "total_results" => 2, "data" => leads} =
                 result
        assert is_list(leads)
        lead_names = (for %{"name" => name} <- leads do
            name
          end)
        assert lead_names == ["Wiley Minogue", "Princess"]
      end
    end
    test "if no leads are found, it returns an empty list" do
      search_term = "FOO"
      use_cassette "find_leads_empty" do
        {:ok, result} = find_leads(search_term)
        assert %{"has_more" => false, "total_results" => 0, "data" => leads} =
                 result
        assert is_list(leads)
        assert leads == []
      end
    end
  end

  describe "find_opportunities/1" do
    test "if some opportunities are found, it returns a list of opportunities" do
      search_term = ~s(opportunity_status:"S01: Received Offer Request")

      use_cassette "find_opportunities" do
        {:ok, result} = find_opportunities(search_term)
        assert %{"data" => opportunities, "total_results" => 48} = result
        assert is_list(opportunities)
        assert Enum.count(opportunities) == 48
        opportunity = hd(opportunities)
        assert opportunity["status_label"] == "S01: Received Offer Request"
      end
    end
    test "if no opportunities are found, it returns an empty list" do
      search_term = "FOO"
      use_cassette "find_opportunities_empty" do
        {:ok, result} = find_opportunities(search_term)
        assert %{"has_more" => false, "total_results" => 0, "data" => opportunities} =
                 result
        assert is_list(opportunities)
        assert opportunities == []
      end
    end
  end

  describe "create_opportunity/1" do
    test "creates an opportunity on CloseIO" do
      use_cassette "create_opportunity", match_requests_on: [:request_body] do
        {:ok, body} = create_opportunity(@valid_opportunity_create_params)
        assert Map.keys(body) ==
                 ["confidence",
                  "contact_id",
                  "contact_name",
                  "created_by",
                  "created_by_name",
                  "date_created",
                  "date_lost",
                  "date_updated",
                  "date_won",
                  "id",
                  "integration_links",
                  "lead_id",
                  "lead_name",
                  "note",
                  "organization_id",
                  "status_id",
                  "status_label",
                  "status_type",
                  "updated_by",
                  "updated_by_name",
                  "user_id",
                  "user_name",
                  "value",
                  "value_currency",
                  "value_formatted",
                  "value_period"]
        assert body["id"] == @created_opportunity_id
      end
    end
    test "returns error for opportunity without lead" do
      use_cassette "create_opportunity_no_lead",
                   match_requests_on: [:request_body] do
        {:error, reason} =
          create_opportunity(@invalid_opportunity_create_params)
        assert reason ==
                 %{
                   "errors" => [],
                   "field-errors" => %{"lead" => "This field is required."},
                 }
      end
    end
  end
  describe "update_opportunity/2" do
    test "when close.io is up and we are passed a valid opportunity_id, it updates and returns the opportunity" do
      use_cassette "update_opportunity", match_requests_on: [:request_body] do
        opportunity_id = @created_opportunity_id
        opportunity = %{"note" => "my_note"}
        {:ok, opportunity_before} = get_opportunity(opportunity_id)
        {:ok, opportunity_after} =
          update_opportunity(opportunity_id, opportunity)
        assert opportunity_before != opportunity_after
        assert opportunity_before["note"] == "i hope this deal closes..."
        assert opportunity_after["note"] == "my_note"
      end
    end
    test "when close.io is up, but the opportunity_id passed is invalid, it fails" do
      use_cassette "update_opportunity_unknown",
                   match_requests_on: [:request_body] do
        {:error, reason} =
          update_opportunity(@invalid_opportunity_id, %{value: 24})
        assert reason ==
                 "Empty query: Opportunity matching query does not exist."
      end
    end
  end
  describe "send_email/1" do
    test "sends an email" do
      email = %{
        "template_id" => @intro_email_template_id,
        "contact_id" => @gob_bluth_contact_id,
        "lead_id" => @valid_lead_id,
        "subject" => "subject",
        "to" => ["test@example.com"],
        "sender" => "Sender <sender@example.com>",
        "status" => "outbox",
      }
      use_cassette "send_email", match_requests_on: [:request_body] do
        {:ok, body} = send_email(email)
        assert Map.keys(body) ==
                 ["_type",
                  "sender",
                  "users",
                  "body_text",
                  "organization_id",
                  "bcc",
                  "body_html_quoted",
                  "created_by",
                  "created_by_name",
                  "id",
                  "date_sent",
                  "date_created",
                  "template_id",
                  "opens_summary",
                  "user_id",
                  "cc",
                  "body_text_quoted",
                  "date_updated",
                  "need_smtp_credentials",
                  "template_name",
                  "updated_by",
                  "status",
                  "message_ids",
                  "thread_id",
                  "send_attempts",
                  "contact_id",
                  "in_reply_to_id",
                  "opens",
                  "attachments",
                  "envelope",
                  "updated_by_name",
                  "lead_id",
                  "references",
                  "direction",
                  "body_preview",
                  "date_scheduled",
                  "to",
                  "email_account_id",
                  "user_name",
                  "subject",
                  "body_html"]
      end
    end
  end
  describe "get_lead_statuses/0" do
    test "fetches a list of all close.io lead statuses" do
      use_cassette "get_lead_statuses" do
        {:ok, response} = get_lead_statuses()
        assert %{"has_more" => false, "data" => statuses} = response
        assert is_list(statuses)
        first_status = List.first(statuses)
        assert is_map(first_status)
        assert first_status["id"] ==
                 "stat_B2vL8OffRrxLAZ3rlwQ5E4To6KbyPfrI2uXJAYhhyYi"
        assert first_status["label"] == "Seller Active"
      end
    end
  end
  describe "get_opportunity_statuses/0" do
    test "fetches a list of all close.io opportunity statuses" do
      use_cassette "get_opportunity_statuses" do
        {:ok, response} = get_opportunity_statuses()
        assert %{"has_more" => false, "data" => statuses} = response
        assert is_list(statuses)
        first_status = List.first(statuses)
        assert is_map(first_status)
        assert first_status["id"] ==
                 "stat_7AT1l4L15KoZWeJlHXminAcPxPG0qKWMRsziU9UOEKH"
        assert first_status["label"] == "S03: Qualified"
        assert first_status["type"] == "active"
      end
    end
  end
  describe "get_users/0" do
    test "fetches a list of close.io users" do
      use_cassette "get_users" do
        {:ok, response} = get_users()
        assert %{"has_more" => false, "data" => users} = response
        assert is_list(users)
        first_user = List.first(users)
        assert is_map(first_user)
        assert first_user["id"] ==
                 "user_3kqxgjklC24LVMT2e0DLILoLqErUeMoJeuURfe1HRP8"
        assert first_user["first_name"] == "Kate"
        assert first_user["last_name"] == "Collins"
      end
    end
  end
  describe ".get_organization/1" do
    test "fetches and returns a CloseIO.Organization" do
      use_cassette "closex_get_organization" do
        {:ok, organization} = get_organization(@organization_id)

        assert Map.keys(organization) == [
          "billing_account_id", "cancellation_date", "created_by", "currency",
          "currency_symbol", "date_created", "date_updated", "id",
          "inactive_memberships", "lead_custom_fields", "lead_statuses", "leads_email",
          "memberships", "name", "opportunity_statuses", "payment_fail_date", "status",
          "trial_ends", "updated_by", "user_count"
        ]

        assert organization["id"] == @organization_id
        assert organization["name"] == "Nested-- DEV"
      end
    end
  end
end
