defmodule MemberTrackingWeb.MembersLive do
  use MemberTrackingWeb, :live_view
  alias MemberTracking.Repo
  alias MemberTracking.Google.GroupMember

  def mount(_params, _session, socket) do
    socket = socket
    |> assign(google_group_members: Repo.all(GroupMember))
    {:ok, socket}
  end
end
