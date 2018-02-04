defmodule Standup.Plugs.OrganizationAuthorizer do
	import Plug.Conn

	alias Standup.Organizations

	@actions [:edit, :delete]

  def init(default), do: default

  def call(%Plug.Conn{:private => %{:phoenix_action => action, :phoenix_controller => StandupWeb.OrganizationController}} = conn, _default) when action in @actions do
		organization = hd(conn.assigns.current_user.organizations)
		if Organizations.is_org_moderator?(conn.assigns.current_user.id, organization.id) do
			assign(conn, :authorized, true)
		else
			assign(conn, :authorized, false)
			Standup.Plugs.Authorizer.unauthorized_user(conn)
		end
	end

	def call(conn, _default), do: conn
end