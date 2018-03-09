defmodule Standup.Plugs.Authorizer do
	use StandupWeb, :controller

  def unauthorized_user(conn) do
    [url] = get_req_header(conn, "referer")
    key = "x-pjax-url"
   # conn = delete_req_header(conn, "x-pjax")
  #  conn = delete_req_header(conn, "x-pjax-container")
    conn = put_resp_header(conn, key, url)
    flash = Map.put(get_flash(conn), "error", "You do not have permission for this request")
    conn = put_session(conn, "pjax_flash", flash)
      conn
        |> put_status(403)
      # |> send_resp(403, "You do not have permission for this request")
        |> put_flash(:error, "You do not have permission for this request")
      #  |> render(StandupWeb.ErrorView, :"403")
        |> redirect(external: url)
      #  |> redirect(to: "/")
        |> halt()
          
        # conn
        #   |> put_flash(:error, "You do not have permission for this request")
        #   |> redirect(to: "/organizations")
        #   |> halt()
  #   env = Application.get_env(:standup, :env)
  #   host = case env do
  #     :dev -> "http://localhost:4000"
  #     :prod -> "https://standup-daily.herokuapp.com"
  #   end
  #   url = String.trim(url, host)
  #   IEx.pry
  #       conn
  #         |> put_flash(:error, "You do not have permission for this request")
  #         |> redirect(to: url)
  #         |> halt()
   end

end