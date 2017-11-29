defmodule StandupWeb.AuthController do
  use StandupWeb, :controller
  plug Ueberauth
  
  require IEx

  alias Ueberauth.Strategy.Helpers
  alias Standup.Accounts
  
  import Standup.Helpers, only: [scrub_get_params: 2]

  plug :scrub_get_params


  def new(conn, _params) do
    render(conn, "new.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"email" => email, "password" => password} = params) 
    when not is_nil(email) and not is_nil(password) do
    IEx.pry
    case Accounts.authenticate(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> render("new.html", callback_url: Helpers.callback_url(conn))
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Email/Password can't be blank")
    |> render("new.html", callback_url: Helpers.callback_url(conn))
  end

end