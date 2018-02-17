defmodule Standup.Auth.CurrentUser do
  import Plug.Conn
  import Guardian.Plug

  alias Standup.Repo

  def init(opts), do: opts
  
  def call(conn, _opts) do
    current_user = current_resource(conn) |> Repo.preload([:credential, :photo, organizations: :work_status_types])
    assign(conn, :current_user, current_user)
  end
end