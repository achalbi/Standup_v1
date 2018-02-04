defmodule Standup.Plugs.Authorizer do
	use StandupWeb, :controller

	def unauthorized_user(conn) do
    [url] = get_req_header(conn, "referer")
        conn
          |> put_flash(:error, "You do not have permission for this request")
          |> redirect(external: url)
          |> halt()
  end

end