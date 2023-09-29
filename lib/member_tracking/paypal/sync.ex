defmodule MemberTracking.Paypal.Sync do
  use GenServer
  alias MemberTracking.Sync
  alias MemberTracking.Paypal
  alias MemberTracking.Paypal.Api
  alias MemberTracking.Airtable
  require Logger
  @tag "paypal"
  @interval_s 24 * 60 * 60 # one day

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_opts) do
    schedule()
    {:ok, nil}
  end

  @impl true
  def handle_info(:sync, _opts) do
    # schedule myself
    Process.send_after(self(), :sync, @interval_s * 1000)
    # get token
    {:ok, {token, _}} = Api.get_token()
    # try and find new subscribers
    sync_recent_transactions(token)
    # update existing subscribers
    update_saved_subscriptions(token)
    # update airtable with new status
    leftover = Airtable.Api.Webhooks.table_id()
    |> Airtable.sync_paypal_records()
    Logger.info("[#{@tag}] could not sync: #{inspect(leftover)}")
    # save last record of sync
    Sync.touch(@tag)
    {:noreply, nil}
  end

  def sync_recent_transactions(token) do
    # list recent transactions
    {:ok, transactions} = Api.Transactions.list(token, Timex.Duration.from_days(4))
    # save all the subscriptions
    total = transactions["transaction_details"]
    |> Enum.map(fn t -> t["transaction_info"] end)
    |> Enum.filter(fn t -> t["paypal_reference_id_type"] == "SUB" end)
    |> Enum.map(fn t -> t["paypal_reference_id"] end)
    |> Enum.map(fn id -> {Api.Subscriptions.details(token, id), Paypal.status(id)} end)
    |> Enum.map(fn {latest, saved} -> add_subscription(latest, saved) end)
    |> Enum.count()
    Logger.info("[#{@tag}] #{total} paypal transactions processed!")
  end

  def update_saved_subscriptions(token) do
    # update existing subscriptions
    total = Paypal.subscriptions() # TODO: don't load it all into memory
    |> Enum.map(fn sub -> {Api.Subscriptions.details(token, sub.subscription), sub} end)
    |> Enum.map(fn {latest, saved} -> add_subscription(latest, saved) end)
    |> Enum.count()
    Logger.info("[#{@tag}] #{total} paypal subscriptions processed!")
  end

  def add_subscription({:ok, latest}, nil) do
    # save the subscription to the database
    {:ok, _} = Paypal.add_subscription(latest)
  end

  def add_subscription({:ok, latest}, sub) do
    # save the subscription only if the status has changed
    if latest["status"] != sub.status do
      {:ok, _} = Paypal.add_subscription(latest)
    end
  end

  defp schedule() do
    next = @interval_s - min(Sync.since(@tag), @interval_s)
    Process.send_after(self(), :sync, next * 1000)
  end
end
