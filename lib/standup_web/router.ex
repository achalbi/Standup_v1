defmodule StandupWeb.Router do
  use StandupWeb, :router

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

  scope "/", StandupWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
  end

  scope "/auth", StandupWeb do
    pipe_through :browser

    get "/:provider", AuthController, :new
    get "/:provider/callback", AuthController, :callback
    post "/identity/callback", AuthController, :callback
    delete "/delete", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", StandupWeb do
  #   pipe_through :api
  # end
end
