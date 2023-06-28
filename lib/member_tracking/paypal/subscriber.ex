defmodule MemberTracking.Paypal.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "paypal_subscribers" do
    field :subscription, :string
    field :subscriber, :string
    field :plan, :string

    field :status, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :last_payment, :map

    field :create, :utc_datetime
    field :start, :utc_datetime
    field :update, :utc_datetime
    field :status_update, :utc_datetime
    field :next_billing_time, :utc_datetime

    timestamps()
  end

  @required [
    :subscription, :subscriber, :plan,
    :status, :email, :first_name, :last_name, :last_payment,
    :create, :start, :update, :status_update, :next_billing_time,
  ]

  @doc false
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, @required)
    |> validate_required(@required)
  end

  def from_subscription(subscription) do
    %__MODULE__{
      subscription: subscription["id"],
      subscriber: subscription["subscriber"]["payer_id"],
      plan: Map.get(subscription, "plan_id"), # can be nil

      status: subscription["status"],
      email: subscription["subscriber"]["email_address"],
      first_name: subscription["subscriber"]["name"]["given_name"],
      last_name: subscription["subscriber"]["name"]["surname"],
      last_payment: subscription["billing_info"]["last_payment"],

      create: time!(subscription["create_time"]),
      start: time!(subscription["start_time"]),
      update: time!(subscription["update_time"]),
      status_update: time!(subscription["status_update_time"]),
      next_billing_time: time!(Map.get(subscription["billing_info"], "next_billing_time")),
    }
  end

  def time!(nil), do: nil
  def time!(time_str) do
    {:ok, datetime, 0} = DateTime.from_iso8601(time_str)
    datetime
  end
end
