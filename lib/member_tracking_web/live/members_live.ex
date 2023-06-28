defmodule MemberTrackingWeb.MembersLive do
  use MemberTrackingWeb, :live_view
  alias MemberTracking.Repo
  alias MemberTracking.Google.GroupMember
  alias MemberTracking.Paypal.Subscriber

  def mount(_params, _session, socket) do
    google = Repo.all(GroupMember)
    |> Enum.map(fn g -> {g.email, %{google: g}} end)
    |> Map.new()
    paypal = Repo.all(Subscriber)
    |> Enum.map(fn p -> {p.email, %{paypal: p}} end)
    |> Map.new()
    people = Map.merge(google, paypal, fn _k, g, p -> Map.merge(g, p) end)

    socket = socket
    |> assign(people: people)
    {:ok, socket}
  end
end
