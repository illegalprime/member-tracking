defmodule MemberTracking.Paypal do
  @moduledoc """
  The Paypal context.
  """

  alias MemberTracking.Repo
  alias MemberTracking.Paypal.Subscriber

  def add_subscription(subscription) do
    Subscriber.from_subscription(subscription)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :subscription)
  end
end
