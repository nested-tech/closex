defmodule Closex.MockClientTest do
  use ExUnit.Case, async: true
  doctest Closex.MockClient
  import Closex.MockClient

  #TODO: Tests around default json files and overriding json files with configuration

  describe "create_lead/2" do
    test "it does a deep merge on the contacts field" do
      payload = %{
        "buyer_address" => "Flat 3, 7 Queensland Road, n7 7ff",
        "contacts" =>  [%{
          "emails" => [%{
            "email" => "domingo.hermiston@gmail.com", "type" => "office"
          }],
          "name" => "Domingo Hermiston",
          "phones" => [%{
            "phone" => "+447840 874446", "type" => "office"
          }]
        }],
        "name" => "Domingo Hermiston", "property_reference_code" => "65616_ErcFletcherCourt",
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
end
