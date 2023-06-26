defmodule MemberTrackingWeb.SubscriberController do
  use MemberTrackingWeb, :controller

  alias MemberTracking.Paypal

  def add(conn, %{"subscriber" => subscriber}) do
    with {:ok, {token, _}} <- Paypal.Api.get_token(),
         {:ok, sub} <- Paypal.Api.Subscriptions.details(token, subscriber),
         {:ok, _} <- Paypal.add_subscription(sub)
    do
      conn
      |> put_status(:created)
      |> render(:created, id: sub.id)
    else
      {:error, %{status_code: 404}} -> conn
      |> put_status(:not_found)
      |> render(:error, msg: "not-found")
      _ -> conn
      |> put_status(:internal_server_error)
      |> render(:error, msg: "unknown")
    end
  end
end
