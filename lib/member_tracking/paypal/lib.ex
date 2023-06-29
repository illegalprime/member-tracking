defmodule MemberTracking.Paypal do
  @moduledoc """
  The Paypal context.
  """
  import Ecto.Query
  alias MemberTracking.Repo
  alias MemberTracking.Paypal.Subscriber

  def add_subscription(subscription) do
    Subscriber.from_subscription(subscription)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :subscription)
  end

  def subscriptions() do
    Repo.all(from p in Subscriber, select: [:subscription, :status])
  end

  def status(id) do
    Repo.one(from p in Subscriber,
      where: p.subscription == ^id, select: [:subscription, :status])
  end
end
