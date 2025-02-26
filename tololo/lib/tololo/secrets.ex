defmodule Tololo.Secrets do
  @moduledoc """
  Secrets for AshAuthentication.
  """
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Tololo.Accounts.User, _opts) do
    Application.fetch_env(:tololo, :token_signing_secret)
  end
end
