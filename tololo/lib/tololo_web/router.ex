defmodule TololoWeb.Router do
  use TololoWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAdmin.Router
  import Plug.BasicAuth

  pipeline :graphql do
    # plug :load_from_bearer
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
    # plug :load_from_bearer
    plug TololoWeb.Deliveries.DeliveryAuthPlug
  end

    pipeline :bot_api do
    plug :accepts, ["json"]
    # plug :check_secret_token
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

    # forward "/telegram", Telegex.Hook.Server,
    #   handler_module: Tololo.Extensions.TelegramBot.Handler

    # auth_routes AuthController, Tololo.Accounts.User, path: "/auth"
    # sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    # sign_in_route register_path: "/register",
    #               reset_path: "/reset",
    #               auth_routes_prefix: "/auth",
    #               on_mount: [{TololoWeb.LiveUserAuth, :live_no_user}],
    #               overrides: [
    #                 TololoWeb.AuthOverrides,
    #                 AshAuthentication.Phoenix.Overrides.Default
    #               ]

    # Remove this if you do not want to use the reset password feature
    # reset_route auth_routes_prefix: "/auth",
    #             overrides: [TololoWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {TololoWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {TololoWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {TololoWeb.LiveUserAuth, :live_no_user}
    end
  end

  scope "/" do
    pipe_through :browser
    pipe_through :admin

    ash_admin("/admin")
  end

  scope "/" do
    pipe_through :bot_api

    post "/telegram", TololoWeb.TelegramController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", TololoWeb do
  #   pipe_through :api
  # end

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
