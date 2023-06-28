defmodule MemberTracking.Paypal.Api.Webhooks do
  alias MemberTracking.Paypal.Api

  def verify(token, params) do
    id = Application.get_env(:member_tracking, __MODULE__)[:id]
    params = Map.put(params, :webhook_id, id) |> Poison.encode!()
    Api.post(token, "notifications/verify-webhook-signature", params)
  end
end

