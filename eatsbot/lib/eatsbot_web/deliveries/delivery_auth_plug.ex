defmodule EatsbotWeb.Deliveries.DeliveryAuthPlug do
  @moduledoc """
  Sets actor of the request, based on the authorization token passed through headers. If there's no authorization header, it returns the conn unmodified. If there's an invalid token, it crashes.
  """
  @behaviour Plug
  import Plug.Conn
  alias AshAuthentication.Plug.Helpers

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%{assigns: %{current_user: %{admin?: true}}} = conn, _opts) do
    conn
    |> assign(:actor, generate_actor(:admin))
    |> Helpers.set_actor(:actor)
  end

  @impl true
  def call(conn, _opts) do
    with false <- Map.has_key?(conn.assigns, :actor),
         ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {actor, resource} <- get_token_data(token) do
      conn
      |> assign(:resource, resource)
      |> assign(:actor, actor)
      |> Helpers.set_actor(:actor)
    else
      _ -> conn
    end
  end

  @spec get_token_data(String.t()) ::
          {%{access_level: atom()}, EatsbotCore.Deliveries.Delivery.t()}
  def get_token_data(token) do
    cond do
      admin?(token) ->
        # admin token isn't related to a resource, so it returns nil
        {generate_actor(:admin), nil}

      [resource] = EatsbotCore.Deliveries.Delivery.get_via_token!(token, authorize?: false) ->
        {generate_actor(token, resource), resource}
    end
  end

  @spec generate_actor(atom()) :: %{access_level: atom()}
  defp generate_actor(:admin), do: EatsbotCore.Deliveries.Actors.admin()

  @spec generate_actor(atom(), EatsbotCore.Deliveries.Delivery.t()) :: %{access_level: atom()}
  defp generate_actor(token, %{public_auth_key: public_key, private_auth_key: private_key}) do
    cond do
      token == public_key -> EatsbotCore.Deliveries.Actors.public()
      token == private_key -> EatsbotCore.Deliveries.Actors.private()
    end
  end

  @spec admin?(String.t()) :: boolean()
  defp admin?(token), do: token == System.get_env("ADMIN_API_KEY")
end
