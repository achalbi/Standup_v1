defmodule StandupWeb.PageController do
  use StandupWeb, :controller

  alias Standup.Accounts
  alias Standup.StatusTrack

  def index(conn, _params) do
    task = nil
    cond do
      Accounts.logged_in?(conn) -> 
        task = StatusTrack.task_last_updated_on(conn)
        render(conn, "index.html", task: task)
      true -> conn |> redirect(to: "/auth/identity")
    end 
    render conn, "index.html", task: task
  end
end
