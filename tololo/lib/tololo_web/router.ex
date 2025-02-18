defmodule TololoWeb.Router do
  use TololoWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAdmin.Router
  import Plug.BasicAuth

  pipeline :graphql do
    plug TololoWeb.Deliveries.DeliveryAuthPlug
    plug AshGraphql.Plug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TololoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug TololoWeb.Deliveries.DeliveryAuthPlug
  end

  pipeline :admin do
    plug :basic_auth, username: "admin", password: System.get_env("ADMIN_API_KEY")
  end

  scope "/gql" do
    pipe_through [:graphql]

    forward "/playground",
            Absinthe.Plug.GraphiQL,
            schema: Module.concat(["TololoWeb.GraphqlSchema"]),
            interface: :playground

    forward "/",
            Absinthe.Plug,
            schema: Module.concat(["TololoWeb.GraphqlSchema"])
  end

  scope "/", TololoWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/map", MapLive
  end

  scope "/" do
    pipe_through :browser
    pipe_through :admin

    ash_admin("/admin")

    live "/deliveries", TololoWeb.DeliveryLive.Index, :index
    live "/deliveries/new", TololoWeb.DeliveryLive.Index, :new
    live "/deliveries/:id/edit", TololoWeb.DeliveryLive.Index, :edit

    live "/deliveries/:id", TololoWeb.DeliveryLive.Show, :show
    live "/deliveries/:id/show/edit", TololoWeb.DeliveryLive.Show, :edit
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tololo, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TololoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
