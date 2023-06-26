defmodule MemberTrackingWeb.SubscriberJSON do
  def created(%{id: id}), do: %{created: id}
  def error(%{msg: err}), do: %{error: err}
end
