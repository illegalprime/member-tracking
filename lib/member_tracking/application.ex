defmodule MemberTracking.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MemberTrackingWeb.Telemetry,
      # Start the Ecto repository
      MemberTracking.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: MemberTracking.PubSub},
      # Start Finch
      {Finch, name: MemberTracking.Finch},
      # Sync google group status every day
      {MemberTracking.Google.Groups, Application.get_env(
          :member_tracking, MemberTracking.Google.Groups)[:group]},
      # Sync PayPal subscriptions every day
      MemberTracking.Paypal.Sync,
      # Listen for changes in Airtable
      {MemberTracking.Airtable.Api.Webhooks,
       MemberTracking.Airtable.Api.Webhooks.table_id()},
      # Start the Endpoint (http/https)
      MemberTrackingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MemberTracking.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MemberTrackingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
