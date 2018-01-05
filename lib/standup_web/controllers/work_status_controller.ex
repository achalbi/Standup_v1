defmodule StandupWeb.WorkStatusController do
  use StandupWeb, :controller

  alias Standup.StatusTrack
  alias Standup.StatusTrack.WorkStatus

  def index(conn, _params) do
    work_statuses = StatusTrack.list_work_statuses()
    render(conn, "index.html", work_statuses: work_statuses)
  end

  def new(conn, _params) do
    changeset = StatusTrack.change_work_status(%WorkStatus{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"work_status" => work_status_params}) do
    case StatusTrack.create_work_status(work_status_params) do
      {:ok, work_status} ->
        conn
        |> put_flash(:info, "Work status created successfully.")
        |> redirect(to: work_status_path(conn, :show, work_status))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    work_status = StatusTrack.get_work_status!(id)
    render(conn, "show.html", work_status: work_status)
  end

  def edit(conn, %{"id" => id}) do
    work_status = StatusTrack.get_work_status!(id)
    changeset = StatusTrack.change_work_status(work_status)
    render(conn, "edit.html", work_status: work_status, changeset: changeset)
  end

  def update(conn, %{"id" => id, "work_status" => work_status_params}) do
    work_status = StatusTrack.get_work_status!(id)

    case StatusTrack.update_work_status(work_status, work_status_params) do
      {:ok, work_status} ->
        conn
        |> put_flash(:info, "Work status updated successfully.")
        |> redirect(to: work_status_path(conn, :show, work_status))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", work_status: work_status, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    work_status = StatusTrack.get_work_status!(id)
    {:ok, _work_status} = StatusTrack.delete_work_status(work_status)

    conn
    |> put_flash(:info, "Work status deleted successfully.")
    |> redirect(to: work_status_path(conn, :index))
  end
end
