defmodule TololoWeb.PageControllerTest do
  use TololoWeb.ConnCase

  def auth_conn(conn),
    do:
      conn
      |> Plug.Conn.put_req_header(
        "authorization",
        "Basic " <> Base.encode64("admin:#{System.get_env("ADMIN_API_KEY")}")
      )

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end

  test "GET /gql/playground", %{conn: conn} do
    conn = get(conn, ~p"/gql/playground")
    assert response(conn, 400)
  end

  test "GET /admin", %{conn: conn} do
    conn =
      conn
      |>auth_conn()
      |> get(~p"/admin")

    assert response(conn, 200)
  end
end
