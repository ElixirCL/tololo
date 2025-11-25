defmodule Eatsbot.Secrets do
  @moduledoc """
  Secrets for AshAuthentication.
  """
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Eatsbot.Accounts.User, _opts) do
    Application.fetch_env(:eatsbot, :token_signing_secret)
  end
end
