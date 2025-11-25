defmodule EatsbotWeb.AuthController do
  use EatsbotWeb, :controller
  use AshAuthentication.Phoenix.Controller
  use Gettext, backend: Eatsbot.Gettext

  def success(conn, activity, user, _token) do
    return_to = get_session(conn, :return_to) || ~p"/"

    message =
      case activity do
        {:confirm_new_user, :confirm} -> gettext("Your email address has now been confirmed")
        {:password, :reset} -> gettext("Your password has successfully been reset")
        _ -> gettext("You are now signed in")
      end

    conn
    |> delete_session(:return_to)
    |> store_in_session(user)
    # If your resource has a different name, update the assign name here (i.e :current_admin)
    |> assign(:current_user, user)
    |> put_flash(:info, message)
    |> redirect(to: return_to)
  end

  def failure(conn, activity, reason) do
    message =
      case {activity, reason} do
        {_,
         %AshAuthentication.Errors.AuthenticationFailed{
           caused_by: %Ash.Error.Forbidden{
             errors: [%AshAuthentication.Errors.CannotConfirmUnconfirmedUser{}]
           }
         }} ->
          gettext("""
          You have already signed in another way, but have not confirmed your account.
          You can confirm your account using the link we sent to you, or by resetting your password.
          """)

        _ ->
          gettext("Incorrect email or password")
      end

    conn
    |> put_flash(:error, message)
    |> redirect(to: ~p"/sign-in")
  end

  def sign_out(conn, _params) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> clear_session()
    |> put_flash(:info, gettext("You are now signed out"))
    |> redirect(to: return_to)
  end
end
