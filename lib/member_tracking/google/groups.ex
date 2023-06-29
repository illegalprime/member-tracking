defmodule MemberTracking.Google.Groups do
  use GenServer
  alias MemberTracking.Sync
  alias MemberTracking.Google.GroupMember
  alias GoogleApi.Admin.Directory_v1.Api
  require Logger
  @tag "google-groups"
  @scope "https://www.googleapis.com/auth/admin.directory.group"
  @interval_s 24 * 60 * 60 # one day

  @impl true
  def handle_info(:sync, group) do
    # run again in one day
    Process.send_after(self(), :sync, @interval_s * 1000)
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
    Sync.touch(@tag)
    Logger.info("[#{@tag}] #{total} members of #{group}!")
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
    schedule()
    {:ok, group}
  end

  defp schedule() do
    next = @interval_s - min(Sync.since(@tag), @interval_s)
    Process.send_after(self(), :sync, next * 1000)
  end

  defp connect() do
    subject = Application.get_env(:member_tracking, __MODULE__)[:admin]
    {:ok, token} = Goth.Token.for_scope(@scope, subject)
    GoogleApi.Admin.Directory_v1.Connection.new(token.token)
  end
end
