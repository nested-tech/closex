defmodule Closex.HTTPClientTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start()
  end

  setup do
    ExVCR.Config.cassette_library_dir("test/fixtures/vcr_cassettes")
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
    "contacts" => [
      %{
        "name" => "Gob",
        "title" => "Sr. Vice President",
        "emails" => [
          %{
            "type" => "office",
            "email" => "gob@example.com"
          }
        ],
        "phones" => [
          %{
            "type" => "office",
            "phone" => "8004445555"
          }
        ]
      }
    ],
    "custom.lcf_RKxL7ypo8Nrqrf5mBX5XQT1502TCIuQXEb2p0w4QvoV" => "Website contact form",
    "custom.lcf_Sr9rVrGnpmRGSS5tSPSqYNcVVIh1JsSU26U30oE6b7y" => "Segway",
    "custom.lcf_uisJjG9EUCD8WpsmEPNFQw6gpB8cxlrf6QEGrmcsqbn" => "Real Estate",
    "addresses" => [
      %{
        "label" => "business",
        "address_1" => "747 Howard St",
        "address_2" => "Room 3",
        "city" => "San Francisco",
        "state" => "CA",
        "zipcode" => "94103",
        "country" => "US"
      }
    ]
  }
  @invalid_create_lead_params %{"status_id" => @invalid_status_id}
  @active_opportunity_status_id "stat_vQWQtofUTvlcdgo1R1lsauc5Inez29fxk0SEOKC8qBg"
  @valid_opportunity_create_params %{
    "note" => "i hope this deal closes...",
    "confidence" => 90,
    "lead_id" => @valid_lead_id,
    "status_id" => @active_opportunity_status_id,
    "value" => 500,
    "value_period" => "monthly"
  }
  @created_opportunity_id "oppo_otkBudcuHXq90sC43gex0ddp5XYQjvKndlOGMHjE9Ph"
  @invalid_opportunity_create_params %{}
  @intro_email_template_id "tmpl_8Mykq86upeoxJGZPkc0debiBLzcjQ5NJnRUo9UJRCMW"
  @gob_bluth_contact_id "cont_CyVw29BYxNQl4bF1FuT04VTjKRtPsHQB1oLMWxFFBLJ"
  @organization_id "orga_CC25dsMNG4KsRpxn2LEwPUVyGRs4poLYFIBsioIK4Oj"
  @valid_task_id "task_OvDSbmI1Gt896KCFsvEcrOVdLYmV07McO6xI0gmXTjr"

  describe "get_lead/1" do
    test "when close.io is up and we are passed a valid lead_id, it returns the lead" do
      use_cassette "get_lead", match_requests_on: [:request_body, :query] do
        {:ok, lead} = get_lead(@valid_lead_id)

        assert Map.keys(lead) ==
                 [
                   "addresses",
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
                   "url"
                 ]

        assert lead["id"] == @valid_lead_id
        assert lead["name"] == "Luke Skywalker"
      end
    end

    test "when close.io is up, but the lead_id passed is invalid, it fails" do
      use_cassette "get_lead_unknown", match_requests_on: [:request_body, :query] do
        {:error, reason} = get_lead(@invalid_lead_id)
        assert reason == "Empty query: Lead matching query does not exist."
      end
    end

    test "with invalid key" do
      use_cassette "get_lead_invalid_key", match_requests_on: [:request_body, :query] do
        {:error, reason} = get_lead(@valid_lead_id)

        assert reason ==
                 "The server could not verify that you are authorized to access the URL requested.  You either supplied the wrong credentials (e.g. a bad password), or your browser doesn't understand how to supply the credentials required."
      end
    end

    test "when server returns 504" do
      use_cassette "get_lead_504" do
        assert {:error, %HTTPoison.Response{status_code: 504}} = get_lead(@valid_lead_id)
      end
    end
  end

  describe "get_opportunity/1" do
    test "when close.io is up and we are passed a valid opportunity_id, it returns the opportunity" do
      use_cassette "get_opportunity", match_requests_on: [:request_body, :query] do
        {:ok, opportunity} = get_opportunity(@valid_opportunity_id)

        assert Map.keys(opportunity) ==
                 [
                   "confidence",
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
                   "value_period"
                 ]

        assert opportunity["id"] == @valid_opportunity_id
        assert opportunity["lead_id"] == "lead_A7hgScTsWRsrRFjvXkghP5mPkJBixfxcBJjgIDGkbuZ"
        assert opportunity["status_id"] == "stat_gc2L6rDDQV9evg1PbdEW0LvgtBrnu1EhMQUgJXZ6Kuy"
        assert opportunity["value"] == 20000
      end
    end

    test "when close.io is up, but the opportunity_id passed is invalid, it fails" do
      use_cassette "get_opportunity_unknown", match_requests_on: [:request_body, :query] do
        {:error, reason} = get_opportunity(@invalid_opportunity_id)
        assert reason == "Empty query: Opportunity matching query does not exist."
      end
    end
  end

  describe "get_lead_custom_field/1" do
    test "fetches and returns a lead custom field if it exists" do
      use_cassette "get_lead_custom_field", match_requests_on: [:request_body, :query] do
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
                   "updated_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW"
                 }
      end
    end

    test "returns error if lead custom field does not exist" do
      use_cassette "get_lead_custom_field_unknown", match_requests_on: [:request_body, :query] do
        {:error, reason} = get_lead_custom_field(@invalid_custom_field_id)
        assert reason == "Empty query: LeadCustomField matching query does not exist."
      end
    end
  end

  describe "create_lead/1" do
    test "when close.io is up and we are passed a valid lead payload, creates a lead on CloseIO" do
      use_cassette "create_lead" do
        {:ok, lead} = create_lead(@valid_create_lead_params)

        assert lead ==
                 %{
                   "addresses" => [
                     %{
                       "address_1" => "747 Howard St",
                       "address_2" => "Room 3",
                       "city" => "San Francisco",
                       "country" => "US",
                       "label" => "business",
                       "state" => "CA",
                       "zipcode" => "94103"
                     }
                   ],
                   "contacts" => [
                     %{
                       "created_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                       "date_created" => "2017-09-29T10:40:23.089000+00:00",
                       "date_updated" => "2017-09-29T10:40:23.089000+00:00",
                       "emails" => [
                         %{
                           "email" => "gob@example.com",
                           "type" => "office"
                         }
                       ],
                       "id" => "cont_CyVw29BYxNQl4bF1FuT04VTjKRtPsHQB1oLMWxFFBLJ",
                       "integration_links" => [],
                       "lead_id" => "lead_ibiNeZe7yE0ZoJZQUKm0Eymg0nxDH2xb5fHg8IzBsAm",
                       "name" => "Gob",
                       "organization_id" => "orga_CC25dsMNG4KsRpxn2LEwPUVyGRs4poLYFIBsioIK4Oj",
                       "phones" => [
                         %{
                           "phone" => "+448004445555",
                           "phone_formatted" => "+44 800 444 5555",
                           "type" => "office"
                         }
                       ],
                       "title" => "Sr. Vice President",
                       "updated_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                       "urls" => []
                     }
                   ],
                   "created_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                   "created_by_name" => "API User (DO NOT DELETE)",
                   "custom" => %{
                     "Google Analytics ID" => "Website contact form",
                     "Mixpanel ID" => "Segway",
                     "Offer ID" => "Real Estate"
                   },
                   "custom.lcf_RKxL7ypo8Nrqrf5mBX5XQT1502TCIuQXEb2p0w4QvoV" =>
                     "Website contact form",
                   "custom.lcf_Sr9rVrGnpmRGSS5tSPSqYNcVVIh1JsSU26U30oE6b7y" => "Segway",
                   "custom.lcf_uisJjG9EUCD8WpsmEPNFQw6gpB8cxlrf6QEGrmcsqbn" => "Real Estate",
                   "date_created" => "2017-09-29T10:40:23.084000+00:00",
                   "date_updated" => "2017-09-29T10:40:23.140000+00:00",
                   "description" => "Best. Show. Ever.",
                   "display_name" => "Bluth Company",
                   "html_url" =>
                     "https://app.close.io/lead/lead_ibiNeZe7yE0ZoJZQUKm0Eymg0nxDH2xb5fHg8IzBsAm/",
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
                   "url" => "http://thebluthcompany.tumblr.com/"
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
                     "status" =>
                       "Not a valid choice. Please go to Customizations in your organization settings and add \"foo\" to the list of lead statuses."
                   }
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
        {:error, reason} = update_lead(@invalid_lead_id, %{"name" => "Bob Fleming"})
        assert reason == "Empty query: Lead matching query does not exist."
      end
    end
  end

  describe "find_leads/1" do
    test "if some leads are found, it returns a list of leads" do
      search_term = "Minogue OR Princess"

      use_cassette "find_leads", match_requests_on: [:request_body, :query] do
        {:ok, result} = find_leads(search_term)
        assert %{"has_more" => false, "total_results" => 2, "data" => leads} = result
        assert is_list(leads)

        lead_names =
          for %{"name" => name} <- leads do
            name
          end

        assert lead_names == ["Wiley Minogue", "Princess"]
      end
    end

    test "if no leads are found, it returns an empty list" do
      search_term = "FOO"

      use_cassette "find_leads_empty", match_requests_on: [:request_body, :query] do
        {:ok, result} = find_leads(search_term)
        assert %{"has_more" => false, "total_results" => 0, "data" => leads} = result
        assert is_list(leads)
        assert leads == []
      end
    end

    test "obeys rate limits, waiting once" do
      use_cassette "find_leads_rate_limit" do
        {:ok, result} = find_leads("Minogue OR Princess", rate_limit_retry: true)

        assert_received {:sleep_mock, [1000]}

        assert %{"has_more" => false, "total_results" => 2, "data" => leads} = result
        assert is_list(leads)

        lead_names =
          for %{"name" => name} <- leads do
            name
          end

        assert lead_names == ["Wiley Minogue", "Princess"]
      end
    end

    test "returns rate limit failures if not configured" do
      use_cassette "find_leads_rate_limit" do
        {:error, result} = find_leads("Minogue OR Princess", rate_limit_retry: false)

        refute_received {:sleep_mock, [1000]}

        assert %{
                 status_code: 429,
                 body: %{"message" => "API call count exceeded for this period"}
               } = result
      end
    end
  end

  describe "find_opportunities/1" do
    test "if some opportunities are found, it returns a list of opportunities" do
      search_term = ~s(opportunity_status:"S01: Received Offer Request")

      use_cassette "find_opportunities", match_requests_on: [:request_body, :query] do
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

      use_cassette "find_opportunities_empty", match_requests_on: [:request_body, :query] do
        {:ok, result} = find_opportunities(search_term)
        assert %{"has_more" => false, "total_results" => 0, "data" => opportunities} = result
        assert is_list(opportunities)
        assert opportunities == []
      end
    end
  end

  describe "create_opportunity/1" do
    test "creates an opportunity on CloseIO" do
      use_cassette "create_opportunity" do
        {:ok, body} = create_opportunity(@valid_opportunity_create_params)

        assert Map.keys(body) ==
                 [
                   "confidence",
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
                   "value_period"
                 ]

        assert body["id"] == @created_opportunity_id
      end
    end

    test "returns error for opportunity without lead" do
      use_cassette "create_opportunity_no_lead", match_requests_on: [:request_body] do
        {:error, reason} = create_opportunity(@invalid_opportunity_create_params)

        assert reason ==
                 %{
                   "errors" => [],
                   "field-errors" => %{"lead" => "This field is required."}
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
        {:ok, opportunity_after} = update_opportunity(opportunity_id, opportunity)
        assert opportunity_before != opportunity_after
        assert opportunity_before["note"] == "i hope this deal closes..."
        assert opportunity_after["note"] == "my_note"
      end
    end

    test "when close.io is up, but the opportunity_id passed is invalid, it fails" do
      use_cassette "update_opportunity_unknown", match_requests_on: [:request_body] do
        {:error, reason} = update_opportunity(@invalid_opportunity_id, %{value: 24})
        assert reason == "Empty query: Opportunity matching query does not exist."
      end
    end
  end

  describe "create_task/2" do
    test "creates a task on CloseIO for the correct lead" do
      use_cassette("create_task", match_requests_on: [:request_body]) do
        text =
          "Very onerous task for which many calls must be made; many notes, written; and many alpacas, shaved."

        {:ok, task} =
          create_task(
            @valid_lead_id,
            text
          )

        assert Map.keys(task) == [
                 "_type",
                 "assigned_to",
                 "assigned_to_name",
                 "contact_id",
                 "contact_name",
                 "created_by",
                 "created_by_name",
                 "date",
                 "date_created",
                 "date_updated",
                 "due_date",
                 "id",
                 "is_complete",
                 "is_dateless",
                 "lead_id",
                 "lead_name",
                 "object_id",
                 "object_type",
                 "organization_id",
                 "text",
                 "updated_by",
                 "updated_by_name",
                 "view"
               ]

        assert task["lead_id"] == @valid_lead_id
        assert task["is_complete"] == false
        assert task["text"] == text
      end
    end

    test "creates a task with optional parameters" do
      use_cassette("create_task_with_params", match_requests_on: [:request_body]) do
        text =
          "Very onerous task for which many calls must be made; many notes, written; and many alpacas, shaved."

        params = %{
          date: "2018-01-01",
          assigned_to: "user_P7CxiTgnGfZBOar8XeKFiRbzCY4LMiDSvGloZ4bpMw9",
          is_complete: true
        }

        {:ok, task} =
          create_task(
            @valid_lead_id,
            text,
            params
          )

        assert task["lead_id"] == @valid_lead_id
        assert task["is_complete"] == true
        assert task["text"] == text
        assert task["due_date"] == params.date
        assert task["assigned_to"] == params.assigned_to
        assert task["assigned_to_name"] == "Developers Developers Developers Developers"
      end
    end

    test "returns an error for invalid lead" do
      use_cassette("create_task_with_invalid_lead", match_requests_on: [:request_body]) do
        text =
          "Very onerous task for which many calls must be made; many notes, written; and many alpacas, shaved."

        {:error, response} =
          create_task(
            @invalid_lead_id,
            text
          )

        assert response == %{
                 "errors" => [],
                 "field-errors" => %{"lead" => "Object does not exist."}
               }
      end
    end
  end

  describe "update_task/2" do
    test "when close.io is up and we are passed a valid task_id, it updates and returns the task" do
      use_cassette "update_task", match_requests_on: [:request_body] do
        task_id = @valid_task_id
        payload = %{"is_complete" => true}
        {:ok, task_after} = update_task(task_id, payload)
        assert task_after["is_complete"] == true
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
        "status" => "outbox"
      }

      use_cassette "send_email" do
        {:ok, body} = send_email(email)

        assert Map.keys(body) ==
                 [
                   "_type",
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
                   "body_html"
                 ]
      end
    end
  end

  describe "get_lead_statuses/0" do
    test "fetches a list of all close.io lead statuses" do
      use_cassette "get_lead_statuses", match_requests_on: [:request_body, :query] do
        {:ok, response} = get_lead_statuses()
        assert %{"has_more" => false, "data" => statuses} = response
        assert is_list(statuses)
        first_status = List.first(statuses)
        assert is_map(first_status)
        assert first_status["id"] == "stat_B2vL8OffRrxLAZ3rlwQ5E4To6KbyPfrI2uXJAYhhyYi"
        assert first_status["label"] == "Seller Active"
      end
    end
  end

  describe "get_opportunity_statuses/0" do
    test "fetches a list of all close.io opportunity statuses" do
      use_cassette "get_opportunity_statuses", match_requests_on: [:request_body, :query] do
        {:ok, response} = get_opportunity_statuses()
        assert %{"has_more" => false, "data" => statuses} = response
        assert is_list(statuses)
        first_status = List.first(statuses)
        assert is_map(first_status)
        assert first_status["id"] == "stat_7AT1l4L15KoZWeJlHXminAcPxPG0qKWMRsziU9UOEKH"
        assert first_status["label"] == "S03: Qualified"
        assert first_status["type"] == "active"
      end
    end
  end

  describe "get_users/0" do
    test "fetches a list of close.io users" do
      use_cassette "get_users", match_requests_on: [:request_body, :query] do
        {:ok, response} = get_users()
        assert %{"has_more" => false, "data" => users} = response
        assert is_list(users)
        first_user = List.first(users)
        assert is_map(first_user)
        assert first_user["id"] == "user_3icdBiVetzNHo1WB5RHkFc2jLlzkrFCbsBx6vMwuQY8"
        assert first_user["first_name"] == "Theo"
        assert first_user["last_name"] == "Margolius"
      end
    end

    test "if close.io times out, it acts as a pass through" do
      use_cassette "get_users_timeout", match_requests_on: [:request_body, :query] do
        {:error, %{reason: "fake_timeout"}} = get_users()
      end
    end
  end

  describe ".get_organization/1" do
    test "fetches and returns a CloseIO.Organization" do
      use_cassette "closex_get_organization", match_requests_on: [:request_body, :query] do
        {:ok, organization} = get_organization(@organization_id)

        assert Map.keys(organization) == [
                 "billing_account_id",
                 "cancellation_date",
                 "created_by",
                 "currency",
                 "currency_symbol",
                 "date_created",
                 "date_updated",
                 "id",
                 "inactive_memberships",
                 "lead_custom_fields",
                 "lead_statuses",
                 "leads_email",
                 "memberships",
                 "name",
                 "opportunity_statuses",
                 "payment_fail_date",
                 "status",
                 "trial_ends",
                 "updated_by",
                 "user_count"
               ]

        assert organization["id"] == @organization_id
        assert organization["name"] == "Nested-- DEV"
      end
    end
  end

  describe "find_all_opportunities/3" do
    test "returns all opportunities from closeio" do
      use_cassette "find_all_opportunities", match_requests_on: [:query] do
        number_of_opportunities_in_closeio_dev_account = 65
        {:ok, response} = find_all_opportunities("opportunity_status_type:active", 45)

        assert %{"has_more" => false, "data" => _opportunities} = response
        assert length(response["data"]) == number_of_opportunities_in_closeio_dev_account
      end
    end
  end

  describe "get_opportunities/1" do
    test "gets opportunities for a lead" do
      use_cassette "get_opportunities_for_lead" do
        {:ok, response} = get_opportunities(params: %{lead_id: @valid_lead_id})

        assert response["data"] |> is_list

        assert hd(response["data"]) |> Map.keys() == [
                 "confidence",
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
                 "value_period"
               ]
      end
    end
  end

  describe "create_note/1" do
    test "creates a note" do
      use_cassette "create_note" do
        {:ok, response} =
          create_note(%{
            lead_id: "lead_s6vHFTK1TSRoH6otXOexWDO9jM4xyb1kELHDoU7Fdsp",
            note: "this is a test note."
          })

        assert response == %{
                 "_type" => "Note",
                 "contact_id" => nil,
                 "created_by" => "user_MvDoAZA889UMrgsZbnXmHkJSomSi7qk2Iwc4JnGHTbo",
                 "created_by_name" => "Bruce Wayne",
                 "date_created" => "2013-02-20T06:39:57.266000+00:00",
                 "date_updated" => "2013-02-20T06:39:57.266000+00:00",
                 "id" => "acti_kwWA3rOfy4BnaZ8QQk3RIIAz51dU9ayiluy1s961Oiw",
                 "lead_id" => "lead_s6vHFTK1TSRoH6otXOexWDO9jM4xyb1kELHDoU7Fdsp",
                 "note" => "this is a test note.",
                 "organization_id" => "orga_bwwWG475zqWiQGur0thQshwVXo8rIYecQHDWFanqhen",
                 "updated_by" => "user_MvDoAZA889UMrgsZbnXmHkJSomSi7qk2Iwc4JnGHTbo",
                 "updated_by_name" => "Bruce Wayne",
                 "user_id" => "user_MvDoAZA889UMrgsZbnXmHkJSomSi7qk2Iwc4JnGHTbo",
                 "user_name" => "Bruce Wayne"
               }
      end
    end
  end

  describe "create_contact/1" do
    test "creates a contact" do
      use_cassette "create_contact" do
        {:ok, response} =
          create_contact(%{
            "lead_id" => @valid_lead_id,
            "name" => "Big Bird",
            "emails" => [%{"email" => "bigbird@example.com", "type" => "office"}],
            "phones" => [%{"phone" => "1234", "type" => "office"}]
          })

        assert response == %{
                 "created_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                 "date_created" => "2018-11-08T10:00:27.780000+00:00",
                 "date_updated" => "2018-11-08T10:00:27.780000+00:00",
                 "display_name" => "Big Bird",
                 "emails" => [%{"email" => "bigbird@example.com", "type" => "office"}],
                 "id" => "cont_pfGqLyh99KXfduS17OnPejhc1fGi4KeHYrMvk4itQQa",
                 "integration_links" => [],
                 "lead_id" => "lead_ibiNeZe7yE0ZoJZQUKm0Eymg0nxDH2xb5fHg8IzBsAm",
                 "name" => "Big Bird",
                 "organization_id" => "orga_CC25dsMNG4KsRpxn2LEwPUVyGRs4poLYFIBsioIK4Oj",
                 "phones" => [
                   %{"phone" => "+441234", "phone_formatted" => "+44 1234", "type" => "office"}
                 ],
                 "title" => "",
                 "updated_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                 "urls" => []
               }
      end
    end
  end

  @valid_contact_id "cont_pfGqLyh99KXfduS17OnPejhc1fGi4KeHYrMvk4itQQa"
  describe "update_contact/2" do
    test "updates a contact" do
      use_cassette "update_contact" do
        {:ok, response} =
          update_contact(@valid_contact_id, %{
            "emails" => [%{"email" => "biggerbird@example.com", "type" => "home"}]
          })

        assert response == %{
                 "created_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                 "date_created" => "2018-11-08T10:00:27.780000+00:00",
                 "date_updated" => "2018-11-08T10:26:25.014000+00:00",
                 "display_name" => "Big Bird",
                 "emails" => [
                   %{"email" => "biggerbird@example.com", "type" => "home"}
                 ],
                 "id" => "cont_pfGqLyh99KXfduS17OnPejhc1fGi4KeHYrMvk4itQQa",
                 "integration_links" => [],
                 "lead_id" => "lead_ibiNeZe7yE0ZoJZQUKm0Eymg0nxDH2xb5fHg8IzBsAm",
                 "name" => "Big Bird",
                 "organization_id" => "orga_CC25dsMNG4KsRpxn2LEwPUVyGRs4poLYFIBsioIK4Oj",
                 "phones" => [
                   %{
                     "phone" => "+441234",
                     "phone_formatted" => "+44 1234",
                     "type" => "office"
                   }
                 ],
                 "title" => "",
                 "updated_by" => "user_CwSfS8J6DsD6tnAsUwNFKCpS7Tq9LVCgJvHapOcpWyW",
                 "urls" => []
               }
      end
    end
  end

  @source_lead_id "lead_8xlzqZBSz6iKJJLoZ82Fh2vqcUzretDDBClxTmWgLJ1"
  @target_lead_id "lead_JFLPvIRrZXv2tSDsApSBlpRlNnNfXNqS0CMkFKV87vX"
  describe "merge_leads/2" do
    test "merges two leads" do
      use_cassette "merge_leads" do
        {:ok, response} = merge_leads(@source_lead_id, @target_lead_id)

        assert response == %{"status" => "ok"}
      end
    end
  end

  describe "log_call/1" do
    test "logs a call activity" do
      call = %{
        "user_id" => "user_weWpqmrZZ9sg3FHYQcUwV7tbwZRpe3sA215Ftv8OvbU",
        "created_by" => "user_weWpqmrZZ9sg3FHYQcUwV7tbwZRpe3sA215Ftv8OvbU",
        "phone" => "+16505551234",
        "direction" => "outbound",
        "status" => "completed",
        "disposition" => "answered",
        "note" => "call originated from mobile",
        "duration" => 345,
        "recording_url" => "some-recording-url.com"
      }

      use_cassette "log_call" do
        {:ok, body} = log_call(call)

        assert Map.keys(body) ==
                 [
                   "source",
                   "_type",
                   "users",
                   "phone",
                   "organization_id",
                   "remote_phone_formatted",
                   "transferred_to",
                   "created_by",
                   "created_by_name",
                   "id",
                   "date_created",
                   "user_id",
                   "date_updated",
                   "local_phone_formatted",
                   "note",
                   "updated_by",
                   "quality_info",
                   "recording_url",
                   "transferred_from",
                   "status",
                   "dialer_id",
                   "call_method",
                   "contact_id",
                   "local_phone",
                   "remote_phone",
                   "has_recording",
                   "updated_by_name",
                   "lead_id",
                   "direction",
                   "duration",
                   "dialer_saved_search_id",
                   "voicemail_duration",
                   "voicemail_url",
                   "user_name",
                   "disposition"
                 ]
      end
    end
  end

  describe "find_phone_numbers/1" do
    test "if some phone_numbers are found, it returns a list of phone_numbers" do
      search_term = "number=+442039742049"

      use_cassette "find_phone_numbers", match_requests_on: [:request_body, :query] do
        {:ok, result} = find_phone_numbers(search_term)
        assert %{"data" => phone_numbers, "has_more" => false} = result
        assert is_list(phone_numbers)
        assert Enum.count(phone_numbers) == 1
        user = hd(phone_numbers)
        assert user["number"] == "+442039742049"
      end
    end

    test "if no phone_numbers are found, it returns an empty list" do
      search_term = "number=thisshouldneverexist"

      use_cassette "find_phone_numbers_empty", match_requests_on: [:request_body, :query] do
        {:ok, result} = find_phone_numbers(search_term)
        assert %{"has_more" => false, "data" => phone_numbers} = result
        assert is_list(phone_numbers)
        assert phone_numbers == []
      end
    end
  end

  describe "create_sms_activity/1" do
    test "creates an sms activity" do
      test_sms = %{
        "status" => "sent",
        "text" => "this is the message body",
        "remote_phone" => "+447946666666",
        "lead_id" => "lead_sA6s1qN2hh1eDHipGxVAKvFlWCEG4xglutTXVUgnNkn",
        "contact_id" => "cont_gwto1MOgh8nNGpCVn5DFJkmMxZYY6oQbh8X9mS5uEXg"
      }

      use_cassette "create_sms_activity" do
        {:ok, body} = create_sms_activity(test_sms)

        assert Map.keys(body) == [
                 "_type",
                 "contact_id",
                 "created_by",
                 "created_by_name",
                 "date_created",
                 "date_scheduled",
                 "date_sent",
                 "date_updated",
                 "direction",
                 "error_message",
                 "id",
                 "lead_id",
                 "local_phone",
                 "local_phone_formatted",
                 "organization_id",
                 "remote_phone",
                 "remote_phone_formatted",
                 "source",
                 "status",
                 "text",
                 "updated_by",
                 "updated_by_name",
                 "user_id",
                 "user_name"
               ]
      end
    end
  end

  describe "find_call_activities/1" do
    test "returns a list of call activities" do
      search_term = "lead_id=lead_ZNjVC99F8sKnz4FWKKCBxIsamaEsasV7kN8aoZCl5zM"

      use_cassette "find_call_activities", match_requests_on: [:request_body, :query] do
        {:ok, result} = find_call_activities(search_term)
        assert %{"data" => call_activities} = result
        assert is_list(call_activities)
        assert Enum.count(call_activities) == 4
        call = hd(call_activities)
        assert call["lead_id"] == "lead_ZNjVC99F8sKnz4FWKKCBxIsamaEsasV7kN8aoZCl5zM"
      end
    end
  end
end
