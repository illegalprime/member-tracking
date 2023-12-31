defmodule MemberTracking.Paypal.Api do
  @base_url "https://api.paypal.com/v1/"

  def get_token() do
    basic_auth = {
      Application.get_env(:member_tracking, __MODULE__)[:client_id],
      Application.get_env(:member_tracking, __MODULE__)[:client_secret],
    }
    headers = %{"Content-Type" => "application/x-www-form-urlencoded"}
    options = [hackney: [basic_auth: basic_auth]]
    form = {:form, [grant_type: "client_credentials"]}

    case HTTPoison.post(@base_url <> "oauth2/token", form, headers, options) do
      {:ok, %{body: body, status_code: 200}} ->
        %{access_token: token, expires_in: expires} = Poison.decode!(body, keys: :atoms)
        {:ok, {token, expires}}
      {_, error} -> {:error, error}
    end
  end

  def get(token, url, params \\ []) do
    case HTTPoison.get(@base_url <> url, headers(token), params: params) do
      {:ok, %{body: body, status_code: 200}} -> {:ok, Poison.decode!(body)}
      {_, error} -> {:error, error}
    end
  end

  def post(token, url, body) do
    case HTTPoison.post(@base_url <> url, body, headers(token)) do
      {:ok, %{body: body, status_code: 200}} -> {:ok, Poison.decode!(body)}
      {_, error} -> {:error, error}
    end
  end

  defp headers(token) do
    %{
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json",
    }
  end
end
