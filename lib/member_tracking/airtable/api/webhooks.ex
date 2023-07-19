defmodule MemberTracking.Airtable.Api.Webhooks do
  use GenServer
  require Logger
  alias MemberTracking.Airtable.Api
  @tag "airtable"

  def create(spec) do
    Api.post("webhooks", Poison.encode!(spec))
  end

  def fetch(id, cursor \\ 1, limit \\ 50) do
    Api.get("webhooks/#{id}/payloads", %{cursor: cursor, limit: limit})
  end

  def refresh(id) do
    Api.post("webhooks/#{id}/refresh")
  end

  def toggle(id, enable) do
    Api.post("webhooks/#{id}/enableNotifications", Poison.encode!(%{enable: enable}))
  end

  def list() do
    Api.get("webhooks")
  end

  def next() do
    GenServer.call(__MODULE__, :next)
  end

  def update_groups(info) do
    GenServer.cast(__MODULE__, {:update_groups, info})
  end

  def start_link(table) do
    GenServer.start_link(__MODULE__, table, name: __MODULE__)
  end

  @impl true
  def init(table) do
    # TODO: don't assume only one webhook
    # check if one exists, we assume the first is ours
    {:ok, webhooks} = list()
    # refresh it daily
    send(self(), :refresh)
    # either make a new one or use the existing data
    case webhooks["webhooks"] |> Enum.at(0) do
      nil ->
        {:ok, %{
            id: create_hook(table)["id"],
            cursor: 1,
            table: table,
         }}
      webhook ->
        {:ok, %{
            id: webhook["id"],
            cursor: webhook["cursorForNextPayload"],
            table: table,
         }}
    end
  end

  @impl true
  def handle_cast({:update_groups, info}, webhook) do
    update = %{
      fields: %{
        "fldy5JHcLmm8I6jta" => info.groups, # TODO: configuration
      }
    }
    {:ok, _} = Api.Records.patch(table_id(), info.record, update)
    {:noreply, webhook}
  end

  @impl true
  def handle_call(:next, _from, webhook) do
    {:ok, response} = fetch(webhook.id, webhook.cursor)
    {:reply, response, %{webhook | cursor: response["cursor"]}}
  end

  @impl true
  def handle_info(:refresh, webhook) do
    Process.send_after(self(), :refresh, 24 * 60 * 60 * 1000)
    Logger.info("[#{@tag}] refreshing webhook")
    refresh(webhook.id)
    {:noreply, webhook}
  end

  defp create_hook(table_id) do
    Logger.info("[#{@tag}] creating new webhook")
    spec = %{
      notificationUrl: "https://members.gbtu.xyz/webhook/airtable",
      specification: %{
        options: %{
          filters: %{
            dataTypes: ["tableData"],
            recordChangeScope: table_id,
          }
        }
      }
    }
    {:ok, webhook} = create(spec)
    webhook
  end

  def table_id() do
    Application.get_env(:member_tracking, MemberTracking.Airtable.Api.Webhooks)[:table]
  end
end
