defmodule MemberTracking.Paypal.Api.Subscriptions do
  alias MemberTracking.Paypal.Api

  def details(token, id) do
    Api.get(token, "billing/subscriptions/#{id}")
  end
end
