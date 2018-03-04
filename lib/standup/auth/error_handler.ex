defmodule Standup.Auth.ErrorHandler do

  alias Ueberauth.Strategy.Helpers
  def auth_error(conn, {_type, _reason}, _opts) do
    #body = Poison.encode!(%{message: to_string(type)})
    #send_resp(conn, 401, body)
    conn
   # |> Phoenix.Controller.put_flash(:error, "You must be signed in to access that page.")
    |> Phoenix.Controller.put_flash(:info, "Please sign into Standup.")
    |> Phoenix.Controller.redirect(to: "/auth/identity", callback_url: Helpers.callback_url(conn)) 
    |> Plug.Conn.halt()
  end
end