defmodule MemberTracking.Google.GroupMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "google_group_members" do
    field :email, :string
    field :group, :string
    field :gid, :string
    field :role, :string
  end

  @doc false
  def changeset(google_group_member, attrs) do
    google_group_member
    |> cast(attrs, [:gid, :email, :group, :role])
    |> validate_required([:gid, :email, :group, :role])
    |> unique_constraint(:gid)
  end

  def new(group, attrs) do
    %{
      email: String.downcase(attrs.email),
      role: attrs.role,
      gid: attrs.id,
      group: group,
    }
  end
end
