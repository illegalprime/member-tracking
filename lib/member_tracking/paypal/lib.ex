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
    Repo.all(from p in Subscriber, select: [:subscription, :status, :email])
  end

  def status(id) do
    Repo.one(from p in Subscriber,
      where: p.subscription == ^id, select: [:subscription, :status])
  end

  def csv(path) do
    text = Repo.all(Subscriber)
    |> Enum.map(fn s -> "#{s.first_name},#{s.last_name},#{s.email},#{s.status}" end)
    |> List.insert_at(0, "first_name,last_name,email,status")
    |> Enum.join("\n")
    File.write(path, text)
  end
end
