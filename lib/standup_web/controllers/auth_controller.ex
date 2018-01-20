defmodule StandupWeb.AuthController do
  use StandupWeb, :controller
  plug Ueberauth
  
  require IEx

  alias Ueberauth.Strategy.Helpers
  alias Standup.Accounts
  alias Standup.Guardian
  
  import Standup.Helpers, only: [scrub_get_params: 2]

  plug :scrub_get_params


  def new(conn, _params) do
    render(conn, "new.html", callback_url: Helpers.callback_url(conn))#, current_user_id: nil)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
  #  |> configure_session(drop: true)
    |> Guardian.Plug.sign_out()
    |> redirect(to: "/auth/identity", callback_url: Helpers.callback_url(conn))#, current_user_id: nil)
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/auth/identity", callback_url: Helpers.callback_url(conn))#, current_user_id: nil)
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.insert_or_update(auth) do
      {:ok, user} ->
        Accounts.link_user_to_org!(user)
        conn
        |> put_flash(:info, user.firstname <> " " <> user.lastname <> " Successfully authenticated.")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: "/")
      {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset, callback_url: Helpers.callback_url(conn))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> render("new.html", callback_url: Helpers.callback_url(conn))#, current_user: nil)
    end
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"email" => email, "password" => password}) 
    when not is_nil(email) and not is_nil(password) do
    case Accounts.authenticate(auth) do
      {:ok, user} ->
        #Accounts.link_user_to_org!(user)
        conn
        |> put_flash(:info, "Successfully authenticated.")
       # |> put_session(:current_user_id, user.id)
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> render("new.html", callback_url: Helpers.callback_url(conn))#, current_user: nil)
    end
  end

  def identity_callback(conn, _params) do
    conn
    |> put_flash(:error, "Email/Password can't be blank")
    |> render("new.html", callback_url: Helpers.callback_url(conn))#, current_user: nil)
  end
end