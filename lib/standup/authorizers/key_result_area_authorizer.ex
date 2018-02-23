defmodule Standup.Plugs.KeyResultAreaAuthorizer do
	import Plug.Conn

	@actions [:index, :new, :edit, :delete]

  def init(default), do: default

  def call(%Plug.Conn{:private => %{:phoenix_action => action, :phoenix_controller => StandupWeb.KeyResultAreaController}} = conn, _default) when action in @actions do
		work_status = Standup.StatusTrack.get_work_status!(conn.params["work_status_id"])
		if conn.assigns.current_user.id == work_status.user_id  do
			assign(conn, :authorized, true)
		else
			assign(conn, :authorized, false)
			Standup.Plugs.Authorizer.unauthorized_user(conn)
		end
	end

	def call(conn, _default), do: conn
end