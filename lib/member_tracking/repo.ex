defmodule MemberTracking.Repo do
  use Ecto.Repo,
    otp_app: :member_tracking,
    adapter: Ecto.Adapters.Postgres
end
