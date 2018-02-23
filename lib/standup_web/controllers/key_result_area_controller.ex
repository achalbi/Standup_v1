defmodule StandupWeb.KeyResultAreaController do
  use StandupWeb, :controller
  plug Standup.Plugs.KeyResultAreaAuthorizer

  require IEx
  alias Standup.StatusTrack
  alias Standup.StatusTrack.KeyResultArea

  def index(conn, %{"work_status_id" => work_status_id}) do
    work_status = StatusTrack.get_work_status!(work_status_id)
    key_result_areas = StatusTrack.list_key_result_areas()
    render(conn, "index.html", key_result_areas: key_result_areas, work_status: work_status)
  end

  def new(conn, %{"work_status_id" => work_status_id}) do
    work_status = StatusTrack.get_work_status!(work_status_id)
    changeset = StatusTrack.change_key_result_area(%KeyResultArea{work_status_id: work_status_id})
    case work_status.key_result_area do
      %KeyResultArea{} = key_result_area -> 
          conn |> redirect(to: work_status_key_result_area_path(conn, :edit, work_status_id, key_result_area))
      _ ->
        render(conn, "new.html", changeset: changeset, work_status: work_status)
    end
  end

  def create(conn, %{"key_result_area" => key_result_area_params, "work_status_id" => work_status_id}) do
    case StatusTrack.create_key_result_area(key_result_area_params) do
      {:ok, key_result_area} ->
        conn
        |> put_flash(:info, "Key result area created successfully.")
        |> redirect(to: work_status_key_result_area_path(conn, :show, work_status_id, key_result_area))
      {:error, %Ecto.Changeset{} = changeset} ->
        work_status = StatusTrack.get_work_status!(work_status_id)
        render(conn, "new.html", changeset: changeset, work_status: work_status)
    end
  end

  def show(conn, %{"id" => id}) do
    key_result_area = StatusTrack.get_key_result_area!(id)
    render(conn, "show.html", key_result_area: key_result_area, work_status: key_result_area.work_status)
  end

  def edit(conn, %{"id" => id}) do
    key_result_area = StatusTrack.get_key_result_area!(id)
    changeset = StatusTrack.change_key_result_area(key_result_area)
    render(conn, "edit.html", key_result_area: key_result_area, changeset: changeset, work_status: key_result_area.work_status)
  end

  def update(conn, %{"id" => id, "key_result_area" => key_result_area_params}) do
    key_result_area = StatusTrack.get_key_result_area!(id)

    case StatusTrack.update_key_result_area(key_result_area, key_result_area_params) do
      {:ok, key_result_area} ->
        conn
        |> put_flash(:info, "Key result area updated successfully.")
        |> redirect(to: work_status_key_result_area_path(conn, :show, key_result_area.work_status, key_result_area, work_status: key_result_area.work_status))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", key_result_area: key_result_area, changeset: changeset, work_status: key_result_area.work_status)
    end
  end

  def delete(conn, %{"id" => id, "work_status_id" => work_status_id}) do
    key_result_area = StatusTrack.get_key_result_area!(id)
    {:ok, _key_result_area} = StatusTrack.delete_key_result_area(key_result_area)

    conn
    |> put_flash(:info, "Key result area deleted successfully.")
    |> redirect(to: work_status_key_result_area_path(conn, :index, work_status_id))
  end
end
