defmodule Closex.MockClientTest do
  use ExUnit.Case, async: true
  doctest Closex.MockClient
  import Closex.MockClient

  # TODO: Tests around default json files and overriding json files with configuration

  describe "create_lead/2" do
    test "it does a deep merge on the contacts field" do
      payload = %{
        "buyer_address" => "Flat 3, 7 Queensland Road, n7 7ff",
        "contacts" => [
          %{
            "emails" => [
              %{
                "email" => "domingo.hermiston@gmail.com",
                "type" => "office"
              }
            ],
            "name" => "Domingo Hermiston",
            "phones" => [
              %{
                "phone" => "+447840 874446",
                "type" => "office"
              }
            ]
          },
          %{
            "emails" => [
              %{
                "email" => "some.bloke@example.com",
                "type" => "office"
              }
            ],
            "name" => "Some Thisreallyismyname Bloke",
            "phones" => [
              %{
                "phone" => "+447777123456",
                "type" => "office"
              }
            ]
          }
        ],
        "name" => "Domingo Hermiston",
        "property_reference_code" => "65616_ErcFletcherCourt",
        "source" => "Rightmove",
        "status_id" => "stat_lvVjyaqI9UCCihDQueGm49zkTF6IOvyRBDHP6tJjfF8",
        "vendor_address" => "FLAT 32, ERIC FLETCHER COURT, Essex Road, London, N1, N1 3PP",
        "vendor_property_details" => "2 bed flat for sale"
      }

      {:ok, %{"contacts" => [primary_contact | _other_contacts]}} = create_lead(payload)

      expected_result = %{
        "created_by" => "user_MvDoAZA889UMrgsZbnXmHkJSomSi7qk2Iwc4JnGHTbo",
        "date_created" => "2013-02-20T05:30:24.844000+00:00",
        "date_updated" => "2013-02-20T05:30:24.844000+00:00",
        "emails" => [%{"email" => "domingo.hermiston@gmail.com", "type" => "office"}],
        "id" => "cont_qpjDKxbN3WWsuhaJjg2Qr9pkqHqe1yviZ5BS0dEyz05",
        "name" => "Domingo Hermiston",
        "organization_id" => "orga_bwwWG475zqWiQGur0thQshwVXo8rIYecQHDWFanqhen",
        "phones" => [%{"phone" => "+447840 874446", "type" => "office"}],
        "title" => "sr. vice president",
        "updated_by" => "user_MvDoAZA889UMrgsZbnXmHkJSomSi7qk2Iwc4JnGHTbo"
      }

      assert ^expected_result = primary_contact
    end

    test "it returns an error if you use the error name" do
      payload = %{
        "name" => Closex.MockClient.error_name()
      }

      {:error, error} = create_lead(payload)

      assert error == %{
               "errors" => [],
               "field-errors" => %{
                 "contacts" => %{
                   "errors" => %{
                     "0" => %{
                       "errors" => [],
                       "field-errors" => %{
                         "phones" => %{
                           "errors" => %{
                             "0" => %{
                               "errors" => [],
                               "field-errors" => %{
                                 "phone" => "Invalid phone number."
                               }
                             }
                           }
                         }
                       }
                     }
                   }
                 }
               }
             }
    end
  end

  describe "find_leads/2" do
    test "it finds a default lead" do
      {:ok, %{"data" => data}} = find_leads("irrelevant query")
      assert length(data) == 1

      assert data |> List.first() |> Map.get("id") ==
               "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O"
    end

    test "it finds multiple results if you give it the multiple results query" do
      {:ok, %{"data" => _, "has_more" => false, "total_results" => 2}} =
        find_leads(Closex.MockClient.multiple_results_query())
    end

    test "it returns timeout if you give it the timout query" do
      assert {:error, %HTTPoison.Error{id: nil, reason: :timeout}} =
               find_leads(Closex.MockClient.timeout_query())
    end

    test "can find custom searches" do
      {:ok, %{"data" => data}} = find_leads("custom query")
      assert length(data) == 1
      assert data |> List.first() |> Map.get("id") == "lead_custom_query_test"
    end
  end

  describe "find_opportunities/2" do
    test "it finds multiple results if you give it the multiple results query" do
      {:ok, %{"data" => data, "has_more" => false}} =
        find_opportunities(Closex.MockClient.multiple_results_query())

      assert length(data) == 3
    end
  end

  describe "update_lead/2" do
    test "it timesout if called with a timeout lead_id" do
      assert {:error, %HTTPoison.Error{id: nil, reason: :timeout}} =
               update_lead(Closex.MockClient.timeout_query(), %{})
    end
  end

  describe "create_task/2" do
    test "it returns a task with the given lead_id and text" do
      {:ok, task} = create_task(Closex.MockClient.lead_id(), "Texty McTexterson")

      assert_received(
        {:closex_mock_client, :create_task, [lead_id, "Texty McTexterson", %{}, []]}
      )

      assert task["text"] == "Texty McTexterson"
      assert task["lead_id"] == lead_id()
    end

    test "it returns a task with the given lead_id and text and with correct params merged in" do
      params = %{
        assigned_to: "user_id",
        date: "2018-02-02",
        not_a_field: "whatevz"
      }

      {:ok, task} = Closex.MockClient.create_task(lead_id(), "Texty McTexterson", params)

      assert_received(
        {:closex_mock_client, :create_task, [lead_id, "Texty McTexterson", ^params, []]}
      )

      assert task["text"] == "Texty McTexterson"
      assert task["lead_id"] == lead_id()
      assert task["assigned_to"] == "user_id"
      assert task["date"] == "2018-02-02"

      refute Map.has_key?(task, :assigned_to)
      refute Map.has_key?(task, :date)
      refute Map.has_key?(task, :not_a_field)
      refute Map.has_key?(task, "not_a_field")
    end

    test "it returns an error for the invalid lead id" do
      lead_id = not_found_id()

      {:error, response} = create_task(lead_id, "Texty McTexterson")

      assert_received(
        {:closex_mock_client, :create_task, [lead_id, "Texty McTexterson", %{}, []]}
      )

      assert response == %{
               "errors" => [],
               "field-errors" => %{"lead" => "Object does not exist."}
             }
    end

    test "it returns an timeout error for the timeout lead it" do
      lead_id = timeout_query()

      {:error, response} = create_task(lead_id, "Texty McTexterson")

      assert_received(
        {:closex_mock_client, :create_task, [lead_id, "Texty McTexterson", %{}, []]}
      )

      assert response == %HTTPoison.Error{id: nil, reason: :timeout}
    end
  end
end
