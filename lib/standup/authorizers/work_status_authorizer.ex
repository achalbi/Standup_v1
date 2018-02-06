defmodule Standup.Plugs.WorkStatusAuthorizer do
	import Plug.Conn

	alias Standup.Organizations

	@actions [:edit, :delete]

  def init(default), do: default

  def call(%Plug.Conn{:private => %{:phoenix_action => action, :phoenix_controller => StandupWeb.WorkStatusController}} = conn, _default) when action in @actions do
        organization = hd(conn.assigns.current_user.organizations)
        work_status = Standup.StatusTrack.get_work_status!(conn.params["id"])
		if Organizations.is_org_moderator?(conn.assigns.current_user.id, organization.id)|| (work_status.user_id == conn.assigns.current_user.id)  do
			assign(conn, :authorized, true)
		else
			assign(conn, :authorized, false)
			Standup.Plugs.Authorizer.unauthorized_user(conn)
		end
	end

	def call(conn, _default), do: conn
end