defmodule EatsbotWeb.DeliveryLive.Show do
  use EatsbotWeb, :live_view

  @actor EatsbotCore.Deliveries.Actors.admin()

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Delivery {@delivery.display_id}
      <:actions>
        <.link patch={~p"/deliveries/#{@delivery}/show/edit"} phx-click={JS.push_focus()}>
          <.button>{gettext("Edit Delivery")}</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="ID">{@delivery.id}</:item>

      <:item title={gettext("Display")}>{@delivery.display_id}</:item>

      <:item title={gettext("State")}>
        {EatsbotCore.Deliveries.Transitions.get_state_string(@delivery.state)}
      </:item>

      <:item title={gettext("Private auth key")}>{@delivery.private_auth_key}</:item>

      <:item title={gettext("Public auth key")}>{@delivery.public_auth_key}</:item>

      <:item title={gettext("Delivery person")}>{inspect(@delivery.delivery_person)}</:item>

      <:item title={gettext("Delivery order")}>{inspect(@delivery.delivery_order)}</:item>

      <:item title={gettext("From latitude")}>{@delivery.from_latitude}</:item>

      <:item title={gettext("From longitude")}>{@delivery.from_longitude}</:item>

      <:item title={gettext("Current latitude")}>{@delivery.current_latitude}</:item>

      <:item title={gettext("Current longitude")}>{@delivery.current_longitude}</:item>

      <:item title={gettext("From name")}>{@delivery.from_name}</:item>

      <:item title={gettext("To latitude")}>{@delivery.to_latitude}</:item>

      <:item title={gettext("To longitude")}>{@delivery.to_longitude}</:item>

      <:item title={gettext("To name")}>{@delivery.to_name}</:item>

      <:item title={gettext("To address")}>{@delivery.to_address}</:item>

      <:item title={gettext("To phone")}>{@delivery.to_phone}</:item>

      <:item title={gettext("To notes")}>{@delivery.to_notes}</:item>

      <:item title={gettext("Delivery started at")}>{@delivery.delivery_started_at}</:item>

      <:item title={gettext("Delivery ended at")}>{@delivery.delivery_ended_at}</:item>
    </.list>

    <.back navigate={~p"/deliveries"}>{gettext("Back to deliveries")}</.back>

    <.modal
      :if={@live_action == :edit}
      id="delivery-modal"
      show
      on_cancel={JS.patch(~p"/deliveries/#{@delivery}")}
    >
      <.live_component
        module={EatsbotWeb.DeliveryLive.FormComponent}
        id={@delivery.id}
        title={@page_title}
        action={@live_action}
        delivery={@delivery}
        patch={~p"/deliveries/#{@delivery}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:delivery, Ash.get!(EatsbotCore.Deliveries.Delivery, id, actor: @actor))}
  end

  defp page_title(:show), do: gettext("Show Delivery")
  defp page_title(:edit), do: gettext("Edit Delivery")
end
