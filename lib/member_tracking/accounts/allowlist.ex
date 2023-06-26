defmodule MemberTracking.Accounts.Allowlist do
  use Ecto.Schema
  import Ecto.Changeset
  alias MemberTracking.Repo

  schema "users_allowlist" do
    field :email, :string
    timestamps()
  end

  @doc false
  def changeset(allowlist, attrs) do
    allowlist
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end

  def allow(email) do
    changeset(%__MODULE__{}, %{email: email}) |> Repo.insert()
  end

  def block(email) do
    find(email) |> Repo.delete()
  end

  def is_allowed(email) do
    find(email) != nil
  end

  def find(email) do
    Repo.get_by(__MODULE__, email: email)
  end
end
