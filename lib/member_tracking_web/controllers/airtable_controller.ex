defmodule MemberTrackingWeb.AirtableController do
  use MemberTrackingWeb, :controller
  alias MemberTracking.Airtable.Api
  alias MemberTracking.Google.Groups
  require Logger

  def webhook(conn, data) do
    Logger.info("Airtable Webhook: #{inspect(data)}")
    Logger.info("Airtable HMAC: #{inspect(conn.resp_headers)}")
    # TODO: verify webhook
    process_webhook()
    conn
    |> put_status(:ok)
    |> text("")
  end

  def process_webhook() do
    webhook = Api.Webhooks.next()
    Enum.map(webhook["payloads"], &process_payload/1)
    if webhook["mightHaveMore"] do
      process_webhook()
    end
  end

  def process_payload(payload) do
    Logger.info("Airtable Info: #{inspect(payload)}")
    %{
      member: member_field,
      locals: locals_field,
    } = google_group_fields()
    table_id = Api.Webhooks.table_id()

    case payload["changedTablesById"] do
      %{^table_id => %{"changedRecordsById" => records}} ->
        Enum.map(records, fn {id, %{"current" => %{"cellValuesByFieldId" => fields}}} ->
          case fields do
            %{^member_field => _} -> membership_trigger(table_id, id)
            %{^locals_field => _} -> membership_trigger(table_id, id)
            _ -> :ok
          end
        end)
      _ -> :ok
    end
  end

  def membership_trigger(table_id, record_id) do
    {:ok, record} = Api.Records.find(table_id, record_id, returnFieldsByFieldId: true)
    google_group_fields()
    |> Enum.map(fn {k, v} -> {k, record["fields"][v]} end)
    |> Enum.concat([id: record_id])
    |> Map.new()
    |> Groups.sync_member()
  end

  def google_group_fields() do
    %{
      member: "fldQu2MqKwiBJqawv",
      locals: "fldQuBofBNRju5QA2",
      email: "fldk3TFCoU9PzWkMj",
    }
  end
end
