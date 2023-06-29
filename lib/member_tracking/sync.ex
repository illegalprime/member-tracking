defmodule MemberTracking.Sync do
  use Ecto.Schema
  import Ecto.Changeset
  alias MemberTracking.Repo

  schema "syncs" do
    field :tag, :string
    field :time, :utc_datetime
  end

  @doc false
  def changeset(sync, attrs) do
    sync
    |> cast(attrs, [:tag, :time])
    |> validate_required([:tag, :time])
  end

  def since(tag) do
    case Repo.get_by(__MODULE__, tag: tag) do
      nil -> nil
      dt -> DateTime.diff(DateTime.utc_now(), dt.time)
    end
  end

  def touch(tag) do
    changeset(%__MODULE__{}, %{tag: tag, time: DateTime.utc_now()})
    |> Repo.insert!(on_conflict: :replace_all, conflict_target: :tag)
  end
end
