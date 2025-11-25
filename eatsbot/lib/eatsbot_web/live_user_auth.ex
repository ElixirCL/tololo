defmodule EatsbotWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  use Gettext, backend: Eatsbot.Gettext
  import Phoenix.Component
  use EatsbotWeb, :verified_routes

  def on_mount(
        :live_user_admin_required,
        _params,
        _session,
        %{assigns: %{current_user: %{admin?: true}}} = socket
      ) do
    {:cont, socket}
  end

  def on_mount(
        :live_user_admin_required,
        _params,
        _session,
        %{assigns: %{current_user: %{admin?: false}}} = _socket
      ),
      do: raise(EatsbotWeb.ForbiddenError, gettext("You don't have access to this page"))

  def on_mount(
        :live_user_admin_required,
        _params,
        _session,
        socket
      ) do
    {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
