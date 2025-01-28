defmodule TololoWeb.DeliveryTest do
  use TololoWeb.ConnCase, async: true

  @init_delivery_query """
    mutation ($input: InitDeliveryInput!) {
      initDelivery(input: $input) {
        result {
          id
          state
          privateAuthKey
          publicAuthKey
          deliveryPerson
          deliveryOrder
          fromLatitude
          fromLongitude
          currentLatitude
          currentLongitude
          fromName
          toLatitude
          toLongitude
          toName
          toAddress
          toPhone
          toNotes
          deliveryStartedAt
          deliveryEndedAt
        }
        errors {
          code
          fields
          message
          shortMessage
          vars
        }
      }
    }
  """

  @get_delivery_query """
    query ($id: ID!) {
      getDelivery(id: $id) {
        id
        state
        privateAuthKey
        publicAuthKey
        deliveryPerson
        deliveryOrder
        fromLatitude
        fromLongitude
        currentLatitude
        currentLongitude
        fromName
        toLatitude
        toLongitude
        toName
        toAddress
        toPhone
        toNotes
        deliveryStartedAt
        deliveryEndedAt
      }
    }
  """

  @update_location_query """
    mutation ($id: ID!, $input: UpdateLocationInput!) {
      updateLocation(id: $id, input: $input) {
        result {
          id
          state
          fromLatitude
          fromLongitude
          currentLatitude
          currentLongitude
          toLatitude
          toLongitude
        }
        errors {
          code
          fields
          message
          shortMessage
          vars
        }
      }
    }
  """

  @update_state_query """
    mutation ($id: ID!, $input: UpdateStateInput!) {
      updateState(id: $id, input: $input) {
        result {
          id
          state
        }
        errors {
          code
          fields
          message
          shortMessage
          vars
        }
      }
    }
  """

  describe "GraphQL endpoints" do
    defp set_gql_headers(conn, auth),
      do:
        conn
        |> put_req_header("accept", "application/graphql-response+json")
        |> put_req_header("content-type", "application/json")
        |> put_req_header("authorization", "Bearer " <> auth)

    test "init delivery", %{conn: conn} do
      variables =
        %{
          input: %{
            delivery_person: "{}",
            delivery_order: "{}",
            from_name: "from_name",
            to_name: "to_name",
            from_latitude: 100,
            from_longitude: 100,
            to_latitude: 100,
            to_longitude: 100,
            to_address: "to_address",
            to_phone: "to_phone",
            to_notes: "to_notes"
          }
        }

      conn =
        conn
        |> set_gql_headers(System.get_env("ADMIN_API_KEY"))
        |> post(
          ~p"/gql",
          %{query: @init_delivery_query, variables: variables}
        )

      %{
        "id" => result_id,
        "publicAuthKey" => public_auth_key,
        "privateAuthKey" => private_auth_key
      } =
        json_response(conn, 200)
        |> Map.get("data")
        |> Map.get("initDelivery")
        |> Map.get("result")

      assert public_auth_key != nil and private_auth_key != nil

      assert Tololo.Deliveries.Delivery
             |> Ash.get!(result_id, authorize?: false)
    end

    test "get delivery", %{conn: conn} do
      %{id: id, public_auth_key: public_auth_key} =
        Tololo.Deliveries.Delivery.empty!(authorize?: false)

      variables = %{id: id}

      conn =
        conn
        |> set_gql_headers(public_auth_key)
        |> post(
          ~p"/gql",
          %{query: @get_delivery_query, variables: variables}
        )

      %{"id" => id, "publicAuthKey" => public_auth_key, "privateAuthKey" => private_auth_key} =
        json_response(conn, 200) |> Map.get("data") |> Map.get("getDelivery")

      assert id != nil
      assert public_auth_key == nil and private_auth_key == nil
    end

    test "update delivery location", %{conn: conn} do
      %{
        id: id,
        private_auth_key: private_auth_key,
        current_latitude: old_lat,
        current_longitude: old_lon
      } =
        Tololo.Deliveries.Delivery.empty!(authorize?: false)
        |> Tololo.Deliveries.Delivery.update_state!(:In_Preparation, authorize?: false)
        |> Tololo.Deliveries.Delivery.update_state!(:Ready_To_Pickup, authorize?: false)
        |> Tololo.Deliveries.Delivery.update_state!(:In_Delivery, authorize?: false)

      variables = %{id: id, input: %{currentLatitude: 123, currentLongitude: 123}}

      conn =
        conn
        |> set_gql_headers(private_auth_key)
        |> post(
          ~p"/gql",
          %{query: @update_location_query, variables: variables}
        )

      %{"id" => id, "currentLatitude" => new_lat, "currentLongitude" => new_lon} =
        json_response(conn, 200)
        |> Map.get("data")
        |> Map.get("updateLocation")
        |> Map.get("result")

      assert id != nil
      assert old_lat != new_lat and old_lon != new_lon
    end

    test "update delivery location unauthorized", %{conn: conn} do
      %{
        id: id,
        public_auth_key: public_auth_key
      } =
        Tololo.Deliveries.Delivery.empty!(authorize?: false)

      variables = %{id: id, input: %{currentLatitude: 123, currentLongitude: 123}}

      conn =
        conn
        |> set_gql_headers(public_auth_key)
        |> post(
          ~p"/gql",
          %{query: @update_location_query, variables: variables}
        )

      [%{"message" => error_message}] =
        json_response(conn, 200)
        |> Map.get("data")
        |> Map.get("updateLocation")
        |> Map.get("errors")

      assert error_message == "forbidden"
    end

    test "update delivery state", %{conn: conn} do
      %{
        id: id,
        private_auth_key: private_auth_key,
        state: old_state
      } =
        Tololo.Deliveries.Delivery.empty!(authorize?: false)

      variables = %{id: id, input: %{state: "In_Preparation"}}

      conn =
        conn
        |> set_gql_headers(private_auth_key)
        |> post(
          ~p"/gql",
          %{query: @update_state_query, variables: variables}
        )

      %{"id" => id, "state" => new_state} =
        json_response(conn, 200)
        |> Map.get("data")
        |> Map.get("updateState")
        |> Map.get("result")

      assert id != nil
      assert new_state != nil and new_state != old_state
    end
  end
end
