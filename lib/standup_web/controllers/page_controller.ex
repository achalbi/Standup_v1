defmodule StandupWeb.PageController do
  use StandupWeb, :controller

  alias Standup.Accounts
  alias Standup.StatusTrack

  def index(conn, _params) do   
    cond do
      Accounts.logged_in?(conn) -> 
        work_status = StatusTrack.work_status_last_updated_on(conn)
        current_user = conn.assigns.current_user
        current_user = Accounts.get_dashboard(current_user)
        organizations = current_user.organizations
        render(conn, "index.html", current_user: current_user, work_status: work_status, organizations: organizations)
      true -> conn |> redirect(to: "/auth/identity")
    end 
  end
end
