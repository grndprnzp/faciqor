defmodule FaciqorWeb.Router do
  use FaciqorWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FaciqorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  scope "/", FaciqorWeb do
    pipe_through :browser

    auth_routes AuthController, Faciqor.Accounts.User
    sign_out_route AuthController

    live_session :public,
      on_mount: [{FaciqorWeb.LiveUserAuth, :live_user_optional}] do
      live "/sign-in", AuthLive, :sign_in
      live "/register", AuthLive, :register
    end

    live_session :restore_account,
      on_mount: [{FaciqorWeb.LiveUserAuth, :live_restore_only}] do
      live "/account/restore", AccountRestoreLive, :restore
    end

    live_session :verify_required,
      on_mount: [{FaciqorWeb.LiveUserAuth, :live_verify_required_only}] do
      live "/verify-email-required", VerifyEmailRequiredLive, :index
    end

    live_session :authenticated,
      on_mount: [{FaciqorWeb.LiveUserAuth, :live_user_required}] do
      live "/", DashboardLive, :index
      live "/dashboard", DashboardLive, :index
      live "/settings/profile", ProfileSettingsLive, :index
      live "/orgs/new", OrgNewLive, :new
      live "/orgs/:handle/settings", OrgSettingsLive, :edit
    end
  end
end
