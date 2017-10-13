defmodule Closex.CachingClientTest do
  use ExUnit.Case, async: true

  describe "get_lead/1" do
    @lead_id "lead_IIDHIStmFcFQZZP0BRe99V1MCoXWz2PGCm6EDmR9v2O"

    test "when called in quick succession returns cached copy" do
      result = Closex.CachingClient.get_lead(@lead_id)

      assert_received {:closex_mock_client, :get_lead, [@lead_id, []]}

      second_result = Closex.CachingClient.get_lead(@lead_id)

      assert result == second_result
      refute_received {:closex_mock_client, :get_lead, _}
    end
  end
end
