defmodule MemberTracking.Repo.Migrations.CreateUsersAllowlist do
  use Ecto.Migration

  def change do
    create table(:users_allowlist) do
      add :email, :string

      timestamps()
    end

    create unique_index(:users_allowlist, [:email])
  end
end
