defmodule Tololo.Accounts.User.Senders.SendMagicLinkEmail do
  @moduledoc """
  Sends a magic link email
  """
  @sender_email Application.compile_env(:tololo, :from_email)
  @subject Application.compile_env(:tololo, :magic_link_subject)

  use AshAuthentication.Sender
  use TololoWeb, :verified_routes

  import Swoosh.Email
  alias Tololo.Mailer

  @impl true
  def send(user_or_email, token, _) do
    # if you get a user, its for a user that already exists.
    # if you get an email, then the user does not yet exist.

    email =
      case user_or_email do
        %{email: email} -> email
        email -> email
      end

    new()
    |> from(@sender_email)
    |> to(to_string(email))
    |> subject(@subject)
    |> html_body(TololoWeb.EmailTemplates.send_magic_link(%{token: token, email: email}))
    |> Mailer.deliver!()
  end
end
