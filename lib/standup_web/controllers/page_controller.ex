defmodule StandupWeb.PageController do
  use StandupWeb, :controller

  alias Standup.Accounts
  def index(conn, _params) do
    cond do
      Accounts.logged_in?(conn) -> render(conn, "index.html")
      true -> conn |> redirect(to: "/auth/identity")
    end 
    render conn, "index.html"
  end
end
