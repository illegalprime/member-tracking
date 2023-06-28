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
      |> render(:created, id: sub["id"])
    else
      {:error, %{status_code: 404}} -> conn
      |> put_status(:not_found)
      |> render(:error, msg: "not-found")
      _ -> conn
      |> put_status(:internal_server_error)
      |> render(:error, msg: "unknown")
    end
  end

  def webhook(conn, %{"resource_type" => "subscription", "resource" => sub} = w) do
    verify_params = %{
      auth_algo: first_header(conn, "paypal-auth-algo"),
      cert_url: first_header(conn, "paypal-cert-url"),
      transmission_id: first_header(conn, "paypal-transmission-id"),
      transmission_sig: first_header(conn, "paypal-transmission-sig"),
      transmission_time: first_header(conn, "paypal-transmission-time"),
      webhook_event: w,
    }
    with {:ok, {token, _}} <- Paypal.Api.get_token(),
         {:ok, _} <- Paypal.Api.Webhooks.verify(token, verify_params),
         {:ok, _} <- Paypal.add_subscription(sub)
    do
      conn
      |> put_status(:ok)
      |> render(:ok)
    else
      _ -> conn
      |> put_status(:internal_server_error)
      |> render(:error, msg: "webhook")
    end
  end

  defp first_header(conn, header) do
    get_req_header(conn, header) |> Enum.at(0)
  end
end
