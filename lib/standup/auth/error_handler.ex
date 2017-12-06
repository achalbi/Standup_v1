defmodule Standup.Auth.ErrorHandler do

  def auth_error(conn, {_type, _reason}, _opts) do
    #body = Poison.encode!(%{message: to_string(type)})
    #send_resp(conn, 401, body)
    conn
    |> Phoenix.Controller.put_flash(:error, "You must be signed in to access that page.")
    |> Phoenix.Controller.redirect(to: "/auth/identity")
  end
end