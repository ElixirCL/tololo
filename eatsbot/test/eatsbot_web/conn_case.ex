defmodule EatsbotWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.
  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use EatsbotWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """
  use ExUnit.CaseTemplate
  import Plug.Conn

  using do
    quote do
      # The default endpoint for testing
      @endpoint EatsbotWeb.Endpoint
      use EatsbotWeb, :verified_routes
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import EatsbotWeb.ConnCase
    end
  end

  setup tags do
    Eatsbot.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn() |> Plug.Test.init_test_session(%{})}
  end

  def admin_session(conn) do
    user =
      Ash.create!(Eatsbot.Accounts.User, %{email: "test@email.com", admin?: true},
        authorize?: false
      )

    conn
    |> fetch_session
    |> put_session("user", AshAuthentication.user_to_subject(user))
    |> put_session("tenant", nil)
    |> put_session("context", nil)
  end
end
