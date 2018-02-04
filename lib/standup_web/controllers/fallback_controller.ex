defmodule StandupWeb.FallbackController do
  use StandupWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> render(StandupWeb.ErrorView, :"403")
  end

  def call(conn, {:error, :unauthorized_webuser}) do
    [url] = get_req_header(conn, "referer")
    conn
      |> put_flash(:error, "You do not have permission for this request")
      |> redirect(external: url)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(StandupWeb.ErrorView, :"404")
  end
end