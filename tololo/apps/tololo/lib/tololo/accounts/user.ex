defmodule Tololo.Accounts.User do
  @moduledoc """
  Represents an user in the Tololo system.

  This module defines the `User` resource, which is responsible for managing authentication.
  """
  use Ash.Resource,
    otp_app: :tololo,
    domain: Tololo.Accounts,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication],
    data_layer: AshPostgres.DataLayer

  authentication do
    tokens do
      enabled? true
      token_resource Tololo.Accounts.Token
      signing_secret Tololo.Secrets
      store_all_tokens? true
    end
  end

  postgres do
    table "users"
    repo Tololo.Repo
  end

  actions do
    defaults [:read]

    read :get_by_subject do
      description "Get a user by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy always() do
      forbid_if always()
    end
  end

  attributes do
    uuid_primary_key :id
  end
end
