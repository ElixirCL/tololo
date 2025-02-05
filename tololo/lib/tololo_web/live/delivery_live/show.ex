defmodule TololoWeb.DeliveryLive.Show do
  use TololoWeb, :live_view

  @actor TololoCore.Deliveries.Actors.admin()

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Delivery {@delivery.id}
      <:subtitle>This is a delivery record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/deliveries/#{@delivery}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit delivery</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@delivery.id}</:item>

      <:item title="Display">{@delivery.display_id}</:item>

      <:item title="State">{@delivery.state}</:item>

      <:item title="Private auth key">{@delivery.private_auth_key}</:item>

      <:item title="Public auth key">{@delivery.public_auth_key}</:item>

      <:item title="Delivery person">{inspect(@delivery.delivery_person)}</:item>

      <:item title="Delivery order">{inspect(@delivery.delivery_order)}</:item>

      <:item title="From latitude">{@delivery.from_latitude}</:item>

      <:item title="From longitude">{@delivery.from_longitude}</:item>

      <:item title="Current latitude">{@delivery.current_latitude}</:item>

      <:item title="Current longitude">{@delivery.current_longitude}</:item>

      <:item title="From name">{@delivery.from_name}</:item>

      <:item title="To latitude">{@delivery.to_latitude}</:item>

      <:item title="To longitude">{@delivery.to_longitude}</:item>

      <:item title="To name">{@delivery.to_name}</:item>

      <:item title="To address">{@delivery.to_address}</:item>

      <:item title="To phone">{@delivery.to_phone}</:item>

      <:item title="To notes">{@delivery.to_notes}</:item>

      <:item title="Delivery started at">{@delivery.delivery_started_at}</:item>

      <:item title="Delivery ended at">{@delivery.delivery_ended_at}</:item>
    </.list>

    <.back navigate={~p"/deliveries"}>Back to deliveries</.back>

    <.modal
      :if={@live_action == :edit}
      id="delivery-modal"
      show
      on_cancel={JS.patch(~p"/deliveries/#{@delivery}")}
    >
      <.live_component
        module={TololoWeb.DeliveryLive.FormComponent}
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
     |> assign(:delivery, Ash.get!(TololoCore.Deliveries.Delivery, id, actor: @actor))}
  end

  defp page_title(:show), do: "Show Delivery"
  defp page_title(:edit), do: "Edit Delivery"
end
