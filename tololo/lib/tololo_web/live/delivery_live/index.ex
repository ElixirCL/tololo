defmodule TololoWeb.DeliveryLive.Index do
  use TololoWeb, :live_view

  @actor TololoCore.Deliveries.Actors.admin()

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Deliveries
      <:actions>
        <.link patch={~p"/deliveries/new"}>
          <.button>New Delivery</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="deliveries"
      rows={@streams.deliveries}
      row_click={fn {_id, delivery} -> JS.navigate(~p"/deliveries/#{delivery}") end}
    >
      <:col :let={{_id, delivery}} label="Display">{delivery.display_id}</:col>

      <:col :let={{_id, delivery}} label="State">{delivery.state}</:col>

      <:col :let={{_id, delivery}} label="To name">{delivery.to_name}</:col>

      <:col :let={{_id, delivery}} label="To address">{delivery.to_address}</:col>

      <:col :let={{_id, delivery}} label="Delivery started at">{delivery.delivery_started_at}</:col>

      <:action :let={{_id, delivery}}>
        <div class="sr-only">
          <.link navigate={~p"/deliveries/#{delivery}"}>Show</.link>
        </div>

        <.link patch={~p"/deliveries/#{delivery}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, delivery}}>
        <.link
          phx-click={JS.push("delete", value: %{id: delivery.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="delivery-modal"
      show
      on_cancel={JS.patch(~p"/deliveries")}
    >
      <.live_component
        module={TololoWeb.DeliveryLive.FormComponent}
        id={(@delivery && @delivery.id) || :new}
        title={@page_title}
        action={@live_action}
        delivery={@delivery}
        patch={~p"/deliveries"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :deliveries, Ash.read!(TololoCore.Deliveries.Delivery, actor: @actor))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Delivery")
    |> assign(:delivery, Ash.get!(TololoCore.Deliveries.Delivery, id, actor: @actor))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Delivery")
    |> assign(:delivery, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Deliveries")
    |> assign(:delivery, nil)
  end

  @impl true
  def handle_info({TololoWeb.DeliveryLive.FormComponent, {:saved, delivery}}, socket) do
    {:noreply, stream_insert(socket, :deliveries, delivery)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    delivery = Ash.get!(TololoCore.Deliveries.Delivery, id, actor: @actor)
    Ash.destroy!(delivery, actor: @actor)

    {:noreply, stream_delete(socket, :deliveries, delivery)}
  end
end
