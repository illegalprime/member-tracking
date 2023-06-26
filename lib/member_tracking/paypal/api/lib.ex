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
        %{access_token: access_token, expires_in: expires_in} = Poison.decode!(body, keys: :atoms)
        {:ok, {access_token, expires_in}}
      {_, error} -> {:error, error}
    end
  end

  def get(token, url) do
    case HTTPoison.get(@base_url <> url, headers(token)) do
      {:ok, %{body: body, status_code: 200}} -> {:ok, Poison.decode!(body, keys: :atoms)}
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
