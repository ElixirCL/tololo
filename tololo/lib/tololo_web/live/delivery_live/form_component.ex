defmodule TololoWeb.DeliveryLive.FormComponent do
  use TololoWeb, :live_component

  @actor TololoCore.Deliveries.Actors.admin()

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage delivery records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="delivery-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:from_name]} type="text" label="From name" />
          <.input field={@form[:to_name]} type="text" label="To name" />
          <.input field={@form[:from_latitude]} type="number" label="From latitude" step="any" />
          <.input field={@form[:from_longitude]} type="number" label="From longitude" step="any" />
          <.input field={@form[:to_latitude]} type="number" label="To latitude" step="any" />
          <.input field={@form[:to_longitude]} type="number" label="To longitude" step="any" />
          <.input field={@form[:to_address]} type="text" label="To address" />
          <.input field={@form[:to_phone]} type="text" label="To phone" />
          <.input field={@form[:to_notes]} type="text" label="To notes" />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input
            field={@form[:state]}
            type="select"
            label="State"
            options={[
              :Init,
              :In_Preparation,
              :Delivery_Aborted,
              :Ready_To_Pickup,
              :In_Delivery,
              :Stale_Delivery_Aborted,
              :Delivery_With_Problems,
              :Delivery_Done,
              :Stale_Delivery_With_Problems,
              :Stale_Delivery_Done
            ]}
          />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Delivery</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"delivery" => delivery_params}, socket) do
    IO.inspect(delivery_params, label: "params")
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
