defmodule MemberTracking.Paypal.Api.Transactions do
  alias MemberTracking.Paypal.Api

  def list(token, duration, params \\ []) do
    Api.get(token, "reporting/transactions", date_range(duration) ++ params)
  end

  defp date_range(duration) do
    timefmt = "{YYYY}-{0M}-{0D}T{h24}:{m}:{s}{Z}"
    [
      start_date: Timex.now() |> Timex.subtract(duration),
      end_date: Timex.now(),
    ]
    |> Enum.map(fn {k, v} -> {k, Timex.format!(v, timefmt)} end)
  end
end
