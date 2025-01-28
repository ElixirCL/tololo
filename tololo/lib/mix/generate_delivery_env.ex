defmodule Mix.Tasks.Generate.Delivery.Env do
  use Mix.Task

  @moduledoc """
  A custom Mix task that initializes a delivery then generates a Bruno environment file for it.

  ## Usage

      mix generate.delivery.env (optional dir)
  """

  @template """
  vars {
    gql_host: 127.0.0.1
    gql_port: 4000
    <%= for {key, value} <- extra_vars do %>
    <%= key %>: <%= value %>
    <% end %>
  }
  """
  @impl Mix.Task
  def run(args) do
    dir = List.first(args) || "../collections/environments"
    Mix.Task.run("app.start")

    %{id: id, public_auth_key: public_auth_key, private_auth_key: private_auth_key} =
      Tololo.Deliveries.Delivery.empty!(authorize?: false)

    output =
      EEx.eval_string(@template,
        extra_vars: %{
          id: id,
          public_auth_key: public_auth_key,
          private_auth_key: private_auth_key,
          admin_auth_key: System.get_env("ADMIN_API_KEY")
        }
      )

    File.write!(dir <> "/generated_env.bru", output)
  end
end
