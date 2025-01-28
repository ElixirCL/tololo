defmodule Tololo.Secrets do
  @moduledoc """
  Module for handling secrets.
  """
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Tololo.Accounts.User, _opts) do
    Application.fetch_env(:tololo, :token_signing_secret)
  end
end
