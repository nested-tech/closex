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
          }
        ],
        "name" => "Domingo Hermiston",
        "property_reference_code" => "65616_ErcFletcherCourt",
        "source" => "Rightmove",
        "status_id" => "stat_lvVjyaqI9UCCihDQueGm49zkTF6IOvyRBDHP6tJjfF8",
        "vendor_address" => "FLAT 32, ERIC FLETCHER COURT, Essex Road, London, N1, N1 3PP",
        "vendor_property_details" => "2 bed flat for sale"
      }

      {:ok, %{"contacts" => [contacts]}} = create_lead(payload)

      result = %{
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

      assert ^result = contacts
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
end
