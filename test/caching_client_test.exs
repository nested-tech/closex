defmodule Closex.CachingClientTest do
  use ExUnit.Case, async: true

  @not_found_id "not_found"

  describe "get_lead/1" do
    @lead_id "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O"

    test "when called in quick succession returns cached copy" do
      fallback = Closex.CachingClient.get_lead(@lead_id)
      assert_received {:closex_mock_client, :get_lead, [@lead_id, []]}

      cache_hit = Closex.CachingClient.get_lead(@lead_id)
      refute_received {:closex_mock_client, :get_lead, _}

      assert fallback == cache_hit
      assert {:ok, %{"id" => @lead_id}} = cache_hit
    end

    test "does not cache error response" do
      {:error, _} = Closex.CachingClient.get_lead(@not_found_id)
      assert_received {:closex_mock_client, :get_lead, [@not_found_id, []]}

      assert {:error, _} = Closex.CachingClient.get_lead(@not_found_id)
      assert_received {:closex_mock_client, :get_lead, [@not_found_id, []]}
    end
  end

  describe "get_opportunity/1" do
    @opportunity_id "oppo_8eB77gAdf8FMy6GsNHEy84f7uoeEWv55slvUjKQZpJt"

    test "when called in quick succession returns cached copy" do
      fallback = Closex.CachingClient.get_opportunity(@opportunity_id)
      assert_received {:closex_mock_client, :get_opportunity, [@opportunity_id, []]}

      cache_hit = Closex.CachingClient.get_opportunity(@opportunity_id)
      refute_received {:closex_mock_client, :get_opportunity, _}

      assert fallback == cache_hit
      assert {:ok, %{"id" => @opportunity_id}} = cache_hit
    end

    test "does not cache error response" do
      {:error, _} = Closex.CachingClient.get_opportunity(@not_found_id)
      assert_received {:closex_mock_client, :get_opportunity, [@not_found_id, []]}

      assert {:error, _} = Closex.CachingClient.get_opportunity(@not_found_id)
      assert_received {:closex_mock_client, :get_opportunity, [@not_found_id, []]}
    end
  end

  describe "get_lead_custom_field/1" do
    @lead_custom_field_id "lcf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c"

    test "when called in quick succession returns cached copy" do
      fallback = Closex.CachingClient.get_lead_custom_field(@lead_custom_field_id)
      assert_received {:closex_mock_client, :get_lead_custom_field, [@lead_custom_field_id, []]}

      cache_hit = Closex.CachingClient.get_lead_custom_field(@lead_custom_field_id)
      refute_received {:closex_mock_client, :get_lead_custom_field, _}

      assert fallback == cache_hit
      assert {:ok, %{"id" => @lead_custom_field_id}} = cache_hit
    end

    test "does not cache error response" do
      {:error, _} = Closex.CachingClient.get_lead_custom_field(@not_found_id)
      assert_received {:closex_mock_client, :get_lead_custom_field, [@not_found_id, []]}

      assert {:error, _} = Closex.CachingClient.get_lead_custom_field(@not_found_id)
      assert_received {:closex_mock_client, :get_lead_custom_field, [@not_found_id, []]}
    end
  end

  describe "get_organization/1" do
    @organization_id "orga_bwwWG475zqWiQGur0thQshwVXo8rIYecQHDWFanqhen"

    test "when called in quick succession returns cached copy" do
      fallback = Closex.CachingClient.get_organization(@organization_id)
      assert_received {:closex_mock_client, :get_organization, [@organization_id, []]}

      cache_hit = Closex.CachingClient.get_organization(@organization_id)
      refute_received {:closex_mock_client, :get_organization, _}

      assert fallback == cache_hit
      assert {:ok, %{"id" => @organization_id}} = cache_hit
    end

    test "does not cache error response" do
      {:error, _} = Closex.CachingClient.get_organization(@not_found_id)
      assert_received {:closex_mock_client, :get_organization, [@not_found_id, []]}

      assert {:error, _} = Closex.CachingClient.get_organization(@not_found_id)
      assert_received {:closex_mock_client, :get_organization, [@not_found_id, []]}
    end
  end

  describe "get_lead_statuses/1" do
    test "when called in quick succession returns cached copy" do
      fallback = Closex.CachingClient.get_lead_statuses
      assert_received {:closex_mock_client, :get_lead_statuses, [[]]}

      cache_hit = Closex.CachingClient.get_lead_statuses
      refute_received {:closex_mock_client, :get_lead_statuses, _}

      assert fallback == cache_hit
      assert {:ok, %{"data" => [_|_]}} = cache_hit
    end
  end

  describe "get_opportunity_statuses/1" do
    test "when called in quick succession returns cached copy" do
      fallback = Closex.CachingClient.get_opportunity_statuses
      assert_received {:closex_mock_client, :get_opportunity_statuses, [[]]}

      cache_hit = Closex.CachingClient.get_opportunity_statuses
      refute_received {:closex_mock_client, :get_opportunity_statuses, _}

      assert fallback == cache_hit
      assert {:ok, %{"data" => [_|_]}} = cache_hit
    end
  end

  describe "get_users/1" do
    test "when called in quick succession returns cached copy" do
      fallback = Closex.CachingClient.get_users
      assert_received {:closex_mock_client, :get_users, [[]]}

      cache_hit = Closex.CachingClient.get_users
      refute_received {:closex_mock_client, :get_users, _}

      assert fallback == cache_hit
      assert {:ok, %{"data" => [_|_]}} = cache_hit
    end
  end

  describe "update_lead/2" do
    @update_lead_id "update_lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O"
    test "invalidates cache when updating lead" do
      result = Closex.CachingClient.get_lead(@update_lead_id)
      assert_received {:closex_mock_client, :get_lead, [@update_lead_id, []]}
      assert Cachex.get!(:closex_cache, @update_lead_id) == result

      {:ok, updated_lead} = Closex.CachingClient.update_lead(@update_lead_id, %{"name" => "New Name"})
      assert_received {:closex_mock_client, :update_lead, [@update_lead_id, %{"name" => "New Name"}, []]}
      assert updated_lead["id"] == @update_lead_id
      assert updated_lead["name"] == "New Name"

      assert Cachex.get(:closex_cache, @update_lead_id) == {:missing, nil}

      {:ok, _lead} = Closex.CachingClient.get_lead(@update_lead_id)
      assert_received {:closex_mock_client, :get_lead, [@update_lead_id, []]}
    end
  end

  describe "update_opportunity/2" do
    @update_opportunity_id "update_oppo_8eB77gAdf8FMy6GsNHEy84f7uoeEWv55slvUjKQZpJt"
    test "invalidates cache when updating opportunity" do
      result = Closex.CachingClient.get_opportunity(@update_opportunity_id)
      assert_received {:closex_mock_client, :get_opportunity, [@update_opportunity_id, []]}
      assert Cachex.get!(:closex_cache, @update_opportunity_id) == result

      {:ok, updated_opportunity} = Closex.CachingClient.update_opportunity(@update_opportunity_id, %{"name" => "New Name"})
      assert_received {:closex_mock_client, :update_opportunity, [@update_opportunity_id, %{"name" => "New Name"}, []]}
      assert updated_opportunity["id"] == @update_opportunity_id
      assert updated_opportunity["name"] == "New Name"

      assert Cachex.get(:closex_cache, @update_opportunity_id) == {:missing, nil}

      {:ok, _opportunity} = Closex.CachingClient.get_opportunity(@update_opportunity_id)
      assert_received {:closex_mock_client, :get_opportunity, [@update_opportunity_id, []]}
    end
  end

  # TODO: tests for other functions
end
