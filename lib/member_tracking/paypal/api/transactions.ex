defmodule MemberTracking.Paypal.Api.Transactions do
  alias MemberTracking.Paypal.Api

  def list(token, params) do
    Api.get(token, "reporting/transactions", params)
  end

  def date_range(n, units) do
    [
      start_date: DateTime.utc_now(),
      end_date: DateTime.utc_now() |> DateTime.add(-n, units),
    ]
    |> Enum.map(fn {k, v} -> {k, DateTime.to_iso8601(v)} end)
  end
end
