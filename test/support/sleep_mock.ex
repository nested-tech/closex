defmodule Closex.SleepMock do
  @moduledoc """
  This is purely for testing purposes to stub out actually sleeping when
  retrying requests; in production we pause to let rate limit windows
  (for example) pass
  """

  def sleep(zzz), do: send(self(), {:sleep_mock, [zzz]})
end
