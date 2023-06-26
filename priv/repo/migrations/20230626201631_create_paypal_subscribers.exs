defmodule MemberTracking.Repo.Migrations.CreatePaypalSubscribers do
  use Ecto.Migration

  def change do
    create table(:paypal_subscribers) do
      add :plan, :string
      add :subscription, :string
      add :subscriber, :string
      add :status, :string
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :last_payment, :map
      add :start, :utc_datetime
      add :create, :utc_datetime
      add :update, :utc_datetime
      add :status_update, :utc_datetime
      add :next_billing_time, :utc_datetime

      timestamps()
    end

    create unique_index(:paypal_subscribers, [:subscription])
  end
end
