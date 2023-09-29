defmodule MemberTracking.Airtable do
  alias MemberTracking.Airtable.Api
  alias MemberTracking.Paypal

  @pp_field "PayPal Email"
  @dues_field "Dues"

  def sync_paypal_records(table) do
    # get every subscriber
    subs = Paypal.subscriptions()
    # only care about emails and if any are active subs
    |> Enum.reduce(%{}, fn sub, acc ->
      active = case Map.get(acc, sub.email) do
        nil -> sub.status == "ACTIVE"
        prev -> prev || sub.status == "ACTIVE"
      end
      Map.put(acc, sub.email, active)
    end)
    # list all records with a dues email
    emails = Api.Records.list(table, filterByFormula: "NOT({#{@pp_field}} = '')")
    # lookup if that email is paying dues
    |> Stream.map(fn record ->
      fields = record["fields"]
      active = Map.get(subs, fields[@pp_field], false)
      {active, fields[@pp_field], !!Map.get(fields, "Dues"), record["id"]}
    end)
    # transform data into an update request
    |> Stream.map(fn {active, email, dues, id} ->
      {active == dues, email, %{id: id, fields: %{@dues_field => active}}}
    end)
    # need the index to chunk just the ones needing changes
    |> Stream.with_index()
    # chunk just those requests that need changes
    |> Stream.chunk_by(fn {{fresh, _, _}, i} -> fresh || div(i, 10) end)
    # run only the updates that are needed and flatten
    |> Stream.flat_map(fn chunk ->
      updates = chunk
      # reject those where airtable == paypal
      |> Enum.reject(fn {{fresh, _, _}, _} -> fresh end)
      # gather all update requests (max 10)
      |> Enum.map(fn {{_, _, update}, _} -> update end)
      # bulk update
      if not Enum.empty?(updates) do
        {:ok, _} = Api.Records.bulk_update(table, updates)
      end
      # keep the chunk for processing
      chunk
    end)
    # extract the emails
    |> Stream.map(fn {{_, email, _}, _} -> email end)
    # unique set of contact emails
    |> Enum.into(MapSet.new())
    # unique set of dues emails
    dues = Map.keys(subs) |> MapSet.new()
    # report weird emails
    %{
      only_airtable: MapSet.difference(emails, dues),
      only_paypal: MapSet.difference(dues, emails)
    }
  end
end
