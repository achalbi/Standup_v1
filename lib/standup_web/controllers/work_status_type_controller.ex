defmodule StandupWeb.WorkStatusTypeController do
  use StandupWeb, :controller
  
  plug Standup.Plugs.WorkStatusTypeAuthorizer
  alias Standup.StatusTrack
  alias Standup.StatusTrack.WorkStatusType

  def index(conn, params) do
    organization_id = params["organization_id"]
    work_status_types = StatusTrack.list_work_status_types(organization_id)
    render(conn, "index.html", work_status_types: work_status_types, organization_id: organization_id)
  end

  def new(conn, params) do
    changeset = StatusTrack.change_work_status_type(%WorkStatusType{})
    organization_id = params["organization_id"]
    render(conn, "new.html", changeset: changeset, organization_id: organization_id)
  end

  def create(conn, %{"work_status_type" => work_status_type_params}) do
    case StatusTrack.create_work_status_type(work_status_type_params) do
      {:ok, work_status_type} ->
        conn
        |> put_flash(:info, "Work status type created successfully.")
        |> redirect(to: organization_work_status_type_path(conn, :show, work_status_type.organization, work_status_type))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    work_status_type = StatusTrack.get_work_status_type!(id)
    render(conn, "show.html", work_status_type: work_status_type)
  end

  def edit(conn, %{"organization_id" => organization_id, "id" => id}) do
    work_status_type = StatusTrack.get_work_status_type!(id)
    changeset = StatusTrack.change_work_status_type(work_status_type)
    render(conn, "edit.html", work_status_type: work_status_type, changeset: changeset, organization_id: organization_id)
  end

  def update(conn, %{"id" => id, "work_status_type" => work_status_type_params}) do
    work_status_type = StatusTrack.get_work_status_type!(id)

    case StatusTrack.update_work_status_type(work_status_type, work_status_type_params) do
      {:ok, work_status_type} ->
        conn
        |> put_flash(:info, "Work status type updated successfully.")
        |> redirect(to: organization_work_status_type_path(conn, :show, work_status_type.organization, work_status_type))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", work_status_type: work_status_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    work_status_type = StatusTrack.get_work_status_type!(id)
    organization_id = work_status_type.organization.id
    {:ok, _work_status_type} = StatusTrack.delete_work_status_type(work_status_type)

    conn
    |> put_flash(:info, "Work status type deleted successfully.")
    |> redirect(to: organization_path(conn, :show, organization_id))
  end
end
