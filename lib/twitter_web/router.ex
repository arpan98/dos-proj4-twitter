defmodule TwitterWeb.Router do
  use TwitterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TwitterWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/login", LoginController, :index
    post "/login/existing", LoginController, :existing
    post "/login/new", LoginController, :new
    post "/login/logout", LoginController, :logout
    post "/login/delete", LoginController, :delete
    get "/home", HomeController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitterWeb do
  #   pipe_through :api
  # end
end
