defmodule StandupWeb.ToDoController do
  use StandupWeb, :controller

  alias Standup.ToDos
  alias Standup.ToDos.ToDo

  def index(conn, %{"organization_id" => organization_id} = params) do
    day = params["day"] || "Today"
    privacy = params["privacy"]
    status = params["status"]
    to_dos = ToDos.list_to_dos(organization_id, day, privacy, status)
    {:ok, datetime} = NaiveDateTime.new(Date.utc_today(), ~T[00:00:00])
    changeset = ToDos.change_to_do(%ToDo{start_date: datetime, end_date: datetime})

    render(
      conn,
      "index.html",
      to_dos: to_dos,
      organization_id: organization_id,
      day: day,
      privacy: privacy,
      status: status,
      changeset: changeset
    )
  end

  def new(conn, %{"organization_id" => organization_id}) do
    {:ok, datetime} = NaiveDateTime.new(Date.utc_today(), ~T[00:00:00])
    changeset = ToDos.change_to_do(%ToDo{start_date: datetime, end_date: datetime})
    render(conn, "new.html", changeset: changeset, organization_id: organization_id)
  end

  def create(conn, %{"to_do" => to_do_params, "organization_id" => organization_id}) do
    current_user_id = conn.assigns.current_user.id
    start_date = Timex.parse!(to_do_params["start_date"], "%Y-%m-%d", :strftime)
    end_date = Timex.parse!(to_do_params["end_date"], "%Y-%m-%d", :strftime)
    to_do_params = Map.put(to_do_params, "start_date", start_date)
    to_do_params = Map.put(to_do_params, "end_date", end_date)
    to_do_params = Map.put(to_do_params, "user_id", current_user_id)
    to_do_params = Map.put(to_do_params, "organization_id", organization_id)

    case ToDos.create_to_do(to_do_params) do
      {:ok, to_do} ->
        conn
        |> put_flash(:info, "To do created successfully.")
        |> redirect(to: organization_to_do_path(conn, :index, organization_id))

      #  |> redirect(to: organization_to_do_path(conn, :show, to_do.organization_id, to_do))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, organization_id: organization_id)
    end
  end

  def show(conn, %{"id" => id}) do
    to_do = ToDos.get_to_do!(id)
    render(conn, "show.html", to_do: to_do, organization_id: to_do.organization_id)
  end

  def edit(conn, %{"id" => id}) do
    to_do = ToDos.get_to_do!(id)
    changeset = ToDos.change_to_do(to_do)

    render(
      conn,
      "edit.html",
      to_do: to_do,
      changeset: changeset,
      organization_id: to_do.organization_id
    )
  end

  def update(conn, %{"id" => id, "to_do" => to_do_params}) do
    to_do = ToDos.get_to_do!(id)
    start_date = Timex.parse!(to_do_params["start_date"], "%Y-%m-%d", :strftime)
    end_date = Timex.parse!(to_do_params["end_date"], "%Y-%m-%d", :strftime)
    to_do_params = Map.put(to_do_params, "start_date", start_date)
    to_do_params = Map.put(to_do_params, "end_date", end_date)

    case ToDos.update_to_do(to_do, to_do_params) do
      {:ok, to_do} ->
        conn
        |> put_flash(:info, "To do updated successfully.")
        |> redirect(to: organization_to_do_path(conn, :show, to_do.organization, to_do))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          to_do: to_do,
          changeset: changeset,
          organization_id: to_do.organization_id
        )
    end
  end

  def delete(conn, %{"id" => id, "organization_id" => organization_id}) do
    to_do = ToDos.get_to_do!(id)
    {:ok, _to_do} = ToDos.delete_to_do(to_do)

    conn
    |> put_flash(:info, "To do deleted successfully.")
    |> redirect(to: organization_to_do_path(conn, :index, organization_id))
  end
end
