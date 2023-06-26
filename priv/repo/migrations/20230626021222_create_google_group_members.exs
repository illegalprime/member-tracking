defmodule MemberTracking.Repo.Migrations.CreateGoogleGroupMembers do
  use Ecto.Migration

  def change do
    create table(:google_group_members) do
      add :gid, :string
      add :email, :string
      add :group, :string
      add :role, :string
    end

    create unique_index(:google_group_members, [:gid])
    create unique_index(:google_group_members, [:email, :group])
  end
end
