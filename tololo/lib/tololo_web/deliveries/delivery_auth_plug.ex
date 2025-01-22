defmodule TololoWeb.Deliveries.DeliveryAuthPlug do
  @moduledoc """
  Sets actor of the request, based on the authorization token passed through headers. If there's no authorization header, it returns the conn unmodified. If there's an invalid token, it crashes.
  """
  @behaviour Plug
  import Plug.Conn
  alias AshAuthentication.Plug.Helpers

  def init(opts), do: opts

  def call(conn, _opts) do
    with [token] <- get_req_header(conn, "authorization"),
         {:ok, {actor, resource}} <- get_token_data(token) do
      conn
      |> assign(:resource, resource)
      |> assign(:actor, actor)
      |> Helpers.set_actor(:actor)
    else
      _ -> conn
    end
  end

  @spec get_token_data(String.t()) :: {:ok, {atom(), Tololo.Deliveries.Delivery.t()}} | :error
  def get_token_data(token) do
    case Tololo.Deliveries.Delivery.get_via_token!(token, authorize?: false) do
      [resource] -> {:ok, {generate_actor(token, resource), resource}}
      _ -> :error
    end
  end

  defp generate_actor(token, %{public_auth_key: public_key, private_auth_key: private_key}) do
    level =
      cond do
        token == public_key -> :public
        token == private_key -> :private
      end

    %{access_level: level}
  end
end
