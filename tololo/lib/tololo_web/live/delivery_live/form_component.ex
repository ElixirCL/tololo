defmodule TololoWeb.DeliveryLive.FormComponent do
  use TololoWeb, :live_component
  alias TololoWeb.DeliveryLive.LocationInputComponent

  @actor TololoCore.Deliveries.Actors.admin()

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="delivery-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:to_name]} type="text" label={gettext("Name")} />
          <.live_component
            module={LocationInputComponent}
            id="to_location"
            lat_field={@form[:to_latitude]}
            lng_field={@form[:to_longitude]}
            address_field={@form[:to_address]}
            label={gettext("Address")}
          />
          <.input field={@form[:to_phone]} type="text" label={gettext("Phone")} />
          <.input
            type="map"
            name="delivery_order"
            fields={[{"name", gettext("Name")}]}
            value={@form[:delivery_order].value}
            label={gettext("Delivery order details")}
          />
          <.input field={@form[:to_notes]} type="text" label={gettext("Notes")} />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input
            field={@form[:state]}
            type="select"
            label={gettext("State")}
            options={@possible_states}
          />
        <% end %>

        <:actions>
          <.button phx-disable-with={gettext("Saving...")}>
            {if @form.source.type == :update,
              do: gettext("Update delivery"),
              else: gettext("Save delivery")}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(possible_states: nil)}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_form()

    current_state = socket.assigns.form[:state].value
    possible_states = TololoCore.Deliveries.Transitions.get_possible_states(current_state)

    {:ok,
     socket
     |> assign(possible_states: possible_states)}
  end

  @impl true
  def handle_event("validate", %{"delivery" => delivery_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, delivery_params))}
  end

  def handle_event("save", %{"delivery" => delivery_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: delivery_params) do
      {:ok, delivery} ->
        notify_parent({:saved, delivery})

        socket =
          socket
          |> put_flash(:info, "Delivery #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{delivery: delivery}} = socket) do
    form =
      if delivery do
        AshPhoenix.Form.for_update(delivery, :update_state,
          as: "delivery",
          actor: @actor
        )
      else
        AshPhoenix.Form.for_create(TololoCore.Deliveries.Delivery, :initialize,
          as: "delivery",
          actor: @actor
        )
      end

    assign(socket, form: to_form(form))
  end
end
