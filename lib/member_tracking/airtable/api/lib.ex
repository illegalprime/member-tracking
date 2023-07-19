defmodule MemberTracking.Airtable.Api do
  def get(url, params \\ []) do
    req(HTTPoison.get(gen_url(url), headers(), params: params))
  end

  def post(url, body \\ "") do
    req(HTTPoison.post(gen_url(url), body, headers()))
  end

  def patch(url, body \\ "") do
    req(HTTPoison.patch(gen_url(url), body, headers()))
  end

  def put(url, body \\ "") do
    req(HTTPoison.put(gen_url(url), body, headers()))
  end

  defp req(request) do
    case request do
      {:ok, %{body: body, status_code: 200}} -> {:ok, Poison.decode!(body)}
      {_, error} -> {:error, error}
    end
  end

  defp gen_url(url) do
    base = Application.get_env(:member_tracking, __MODULE__)[:base]
    case String.starts_with?(url, "webhooks") do
      false -> "https://api.airtable.com/v0/#{base}/#{url}"
      true -> "https://api.airtable.com/v0/bases/#{base}/#{url}"
    end
  end

  defp headers() do
    token = Application.get_env(:member_tracking, __MODULE__)[:token]
    %{
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json",
    }
  end
end
