defmodule MemberTracking.Google.Groups do
  use GenServer
  alias MemberTracking.Google.GroupMember
  alias GoogleApi.Admin.Directory_v1.Api
  require Logger
  @scope "https://www.googleapis.com/auth/admin.directory.group"

  @impl true
  def handle_info(:sync, group) do
    # run again in one day
    schedule()
    # fold through pages of members of google group
    total = fold_members(group, 0, fn acc, members ->
      # create change set for database
      members = Enum.map(members.members, fn m -> GroupMember.new(group, m) end)
      # update database
      MemberTracking.Repo.insert_all(
        GroupMember,
        members,
        on_conflict: :replace_all,
        conflict_target: :gid
      )
      acc + Enum.count(members)
    end)
    # log it
    Logger.info("[google-group-sync] #{total} members of #{group}!")
    {:noreply, group}
  end

  def fold_members(group, acc, f, page \\ nil) do
    {:ok, members} = Api.Members.directory_members_list(connect(), group, pageToken: page)
    r = f.(acc, members)
    case members.nextPageToken do
      nil -> r
      nxt -> fold_members(group, r, f, nxt)
    end
  end

  def start_link(group) do
    GenServer.start_link(__MODULE__, group)
  end

  @impl true
  def init(group) do
    send(self(), :sync)
    {:ok, group}
  end

  defp schedule() do
    Process.send_after(self(), :sync, 24 * 60 * 60 * 1000) # one day
  end

  defp connect() do
    subject = Application.get_env(:member_tracking, __MODULE__)[:admin]
    {:ok, token} = Goth.Token.for_scope(@scope, subject)
    GoogleApi.Admin.Directory_v1.Connection.new(token.token)
  end
end
