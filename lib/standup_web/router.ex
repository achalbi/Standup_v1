defmodule StandupWeb.Router do
  use StandupWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # pipeline :browser_auth do
  #   plug Guardian.Plug.VerifySession
  #   plug Guardian.Plug.EnsureAuthenticated, handler: Standup.AuthErrorHandler
  #   plug Guardian.Plug.LoadResource, allow_blank: true
  #   plug Standup.CurrentUser
  # end

  # pipeline :api do
  #   plug :accepts, ["json"]
  # end
  pipeline :browser_session do
    plug Standup.Guardian.AuthPipeline.Browser
    plug Standup.Auth.CurrentUser
  end
  
  pipeline :login_required do
    plug Standup.Guardian.AuthPipeline.Authenticate
  end

  # pipeline :authorize_admin do
  #   plug Standup.Guardian.AuthPipeline.Authenticate
  #   plug Standup.Auth.Authorize, :admin
  # end

  pipeline :api do
    plug :accepts, ["json"]
    plug Standup.Guardian.AuthPipeline.JSON
  end

  scope "/auth", StandupWeb do
    pipe_through [:browser, :browser_session]
    
    get "/:provider", AuthController, :new
    get "/:provider/callback", AuthController, :callback
    post "/identity/callback", AuthController, :identity_callback
    delete "/delete", AuthController, :delete
  end
  
  scope "/", StandupWeb do
    pipe_through [:browser, :browser_session]
    
    resources "/users", UserController, only: [:new, :create]
  end

  scope "/", StandupWeb do
    pipe_through [:browser, :browser_session, :login_required] # Use the default browser stack
    
    get "/", PageController, :index
    resources "/users", UserController, except: [:new, :create]
    resources "/roles", RoleController
    resources "/organizations", OrganizationController do
      resources "/domains", DomainController
    end
    resources "/teams", TeamController do
      get "/add_users", TeamController, :add_users, as: :add_users
      get "/remove_users", TeamController, :remove_users, as: :remove_users
    end
    post "/photos/upload", PhotoController, :upload 
    resources "/work_statuses", WorkStatusController
    resources "/tasks", TaskController
  end
  # Other scopes may use custom stacks.
  # scope "/api", StandupWeb do
  #   pipe_through :api
  # end
end
