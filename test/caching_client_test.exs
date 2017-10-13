defmodule Closex.CachingClientTest do
  use ExUnit.Case, async: true

  @not_found_id "not_found"

  describe "get_lead/1" do
    @lead_id "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O"

    test "when called in quick succession returns cached copy" do
      {:loaded, fallback} = Closex.CachingClient.get_lead(@lead_id)
      assert_received {:closex_mock_client, :get_lead, [@lead_id, []]}

      assert {:ok, cache_hit} = Closex.CachingClient.get_lead(@lead_id)
      refute_received {:closex_mock_client, :get_lead, _}

      assert fallback == cache_hit
      assert {:ok, %{"id" => @lead_id}} = cache_hit
    end

    test "does not cache error response" do
      {:loaded, {:error, _}} = Closex.CachingClient.get_lead(@not_found_id)
      assert_received {:closex_mock_client, :get_lead, [@not_found_id, []]}

      assert {:loaded, {:error, _}} = Closex.CachingClient.get_lead(@not_found_id)
      assert_received {:closex_mock_client, :get_lead, [@not_found_id, []]}
    end
  end
end
