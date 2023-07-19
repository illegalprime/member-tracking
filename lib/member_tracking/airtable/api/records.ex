defmodule MemberTracking.Airtable.Api.Records do
  alias MemberTracking.Airtable.Api

  def list(table, params \\ []) do
    Api.get(table, params)
  end

  def find(table, record, params \\ []) do
    Api.get("#{table}/#{record}", params)
  end

  def patch(table, record, params \\ %{}) do
    Api.patch("#{table}/#{record}", Poison.encode!(params))
  end
end
