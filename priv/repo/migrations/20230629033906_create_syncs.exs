defmodule MemberTracking.Repo.Migrations.CreateSyncs do
  use Ecto.Migration

  def change do
    create table(:syncs) do
      add :tag, :string
      add :time, :utc_datetime
    end

    create unique_index(:syncs, [:tag])
  end
end
