defmodule MemberTracking.Airtable.Api.Records do
  alias MemberTracking.Airtable.Api

  def list(table, params \\ []) do
    Stream.resource(fn -> nil end, fn offset ->
      case offset do
        :end -> {:halt, :ok}
        page ->
          {:ok, records} = Api.get(table, [offset: page] ++ params)
          {records["records"], Map.get(records, "offset", :end)}
      end
    end, fn out -> out end)
  end

  def find(table, record, params \\ []) do
    Api.get("#{table}/#{record}", params)
  end

  def patch(table, record, params \\ %{}) do
    Api.patch("#{table}/#{record}", Poison.encode!(params))
  end

  def bulk_update(table, records \\ []) do
    Api.patch("#{table}", Poison.encode!(%{records: records}))
  end
end
