defmodule StandupWeb.ToDoController do
  use StandupWeb, :controller

  alias Standup.ToDos
  alias Standup.ToDos.ToDo

  def index(conn, _params) do
    to_dos = ToDos.list_to_dos()
    render(conn, "index.html", to_dos: to_dos)
  end

  def new(conn, _params) do
    changeset = ToDos.change_to_do(%ToDo{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"to_do" => to_do_params}) do
    case ToDos.create_to_do(to_do_params) do
      {:ok, to_do} ->
        conn
        |> put_flash(:info, "To do created successfully.")
        |> redirect(to: to_do_path(conn, :show, to_do))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    to_do = ToDos.get_to_do!(id)
    render(conn, "show.html", to_do: to_do)
  end

  def edit(conn, %{"id" => id}) do
    to_do = ToDos.get_to_do!(id)
    changeset = ToDos.change_to_do(to_do)
    render(conn, "edit.html", to_do: to_do, changeset: changeset)
  end

  def update(conn, %{"id" => id, "to_do" => to_do_params}) do
    to_do = ToDos.get_to_do!(id)

    case ToDos.update_to_do(to_do, to_do_params) do
      {:ok, to_do} ->
        conn
        |> put_flash(:info, "To do updated successfully.")
        |> redirect(to: to_do_path(conn, :show, to_do))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", to_do: to_do, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    to_do = ToDos.get_to_do!(id)
    {:ok, _to_do} = ToDos.delete_to_do(to_do)

    conn
    |> put_flash(:info, "To do deleted successfully.")
    |> redirect(to: to_do_path(conn, :index))
  end
end
