defmodule Standup.Plugs.Authorizer do
	use StandupWeb, :controller

  require IEx
  def unauthorized_user(conn) do
    IEx.pry
    [url] = get_req_header(conn, "referer")
    key = "x-pjax-url"
    value = url
    conn = put_req_header(conn, key, value)
        conn
          |> put_flash(:error, "You do not have permission for this request")
          |> redirect(to: url)
          |> halt()
    # env = Application.get_env(:standup, :env)
    # host = case env do
    #   :dev -> "http://localhost:4000"
    #   :prod -> "https://standup-daily.herokuapp.com"
    # end
    # url = String.trim(url, host)
    #     conn
    #       |> put_flash(:error, "You do not have permission for this request")
    #       |> redirect(to: url)
    #       |> halt()
  end

end