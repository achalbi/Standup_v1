defmodule Standup.Auth.ErrorHandler do
  use StandupWeb, :controller
  
  alias Ueberauth.Strategy.Helpers
  
  #import Plug.Conn


  def auth_error(conn, {_type, _reason}, _opts) do
    #body = Poison.encode!(%{message: to_string(type)})
    #send_resp(conn, 401, body)
    conn
    |> redirect(to: "/auth/identity", callback_url: Helpers.callback_url(conn))
  end
end