defmodule EatsbotWeb.DeliveryLive.Index do
  use EatsbotWeb, :live_view

  @actor EatsbotCore.Deliveries.Actors.admin()

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {gettext("Listing Deliveries")}
      <:actions>
        <.link patch={~p"/deliveries/new"}>
          <.button>{gettext("New Delivery")}</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="deliveries"
      rows={@streams.deliveries}
      row_click={fn {_id, delivery} -> JS.navigate(~p"/deliveries/#{delivery}") end}
    >
      <:col :let={{_id, delivery}} label={gettext("Display")}>{delivery.display_id}</:col>

      <:col :let={{_id, delivery}} label={gettext("State")}>
        {EatsbotCore.Deliveries.Transitions.get_state_string(delivery.state)}
      </:col>

      <:col :let={{_id, delivery}} label={gettext("To name")}>{delivery.to_name}</:col>

      <:col :let={{_id, delivery}} label={gettext("To address")}>{delivery.to_address}</:col>

      <:col :let={{_id, delivery}} label={gettext("Delivery started at")}>
        {delivery.delivery_started_at}
      </:col>

      <:action :let={{_id, delivery}}>
        <div class="sr-only">
          <.link navigate={~p"/deliveries/#{delivery}"}>{gettext("Show")}</.link>
        </div>

        <.link patch={~p"/deliveries/#{delivery}/edit"}>{gettext("Edit")}</.link>
      </:action>

      <:action :let={{id, delivery}}>
        <.link
          phx-click={JS.push("delete", value: %{id: delivery.id}) |> hide("##{id}")}
          data-confirm={gettext("Are you sure?")}
        >
          {gettext("Delete")}
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
        module={EatsbotWeb.DeliveryLive.FormComponent}
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
    {:ok, stream(socket, :deliveries, Ash.read!(EatsbotCore.Deliveries.Delivery, actor: @actor))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Edit Delivery"))
    |> assign(:delivery, Ash.get!(EatsbotCore.Deliveries.Delivery, id, actor: @actor))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Delivery"))
    |> assign(:delivery, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Deliveries"))
    |> assign(:delivery, nil)
  end

  @impl true
  def handle_info({EatsbotWeb.DeliveryLive.FormComponent, {:saved, delivery}}, socket) do
    {:noreply, stream_insert(socket, :deliveries, delivery)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    delivery = Ash.get!(EatsbotCore.Deliveries.Delivery, id, actor: @actor)
    Ash.destroy!(delivery, actor: @actor)

    {:noreply, stream_delete(socket, :deliveries, delivery)}
  end
end
