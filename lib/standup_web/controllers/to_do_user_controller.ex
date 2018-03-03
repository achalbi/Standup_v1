defmodule StandupWeb.ToDoUserController do
  use StandupWeb, :controller

  alias Standup.ToDos
  alias Standup.ToDos.ToDoUser

  def index(conn, _params) do
    to_do_users = ToDos.list_to_do_users()
    render(conn, "index.html", to_do_users: to_do_users)
  end

  def new(conn, _params) do
    changeset = ToDos.change_to_do_user(%ToDoUser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"to_do_user" => to_do_user_params}) do
    case ToDos.create_to_do_user(to_do_user_params) do
      {:ok, to_do_user} ->
        conn
        |> put_flash(:info, "To do user created successfully.")
 #       |> redirect(to: to_do_user_path(conn, :show, to_do_user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    to_do_user = ToDos.get_to_do_user!(id)
    render(conn, "show.html", to_do_user: to_do_user)
  end

  def edit(conn, %{"id" => id}) do
    to_do_user = ToDos.get_to_do_user!(id)
    changeset = ToDos.change_to_do_user(to_do_user)
    render(conn, "edit.html", to_do_user: to_do_user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "to_do_user" => to_do_user_params}) do
    to_do_user = ToDos.get_to_do_user!(id)

    case ToDos.update_to_do_user(to_do_user, to_do_user_params) do
      {:ok, to_do_user} ->
        conn
        |> put_flash(:info, "To do user updated successfully.")
  #      |> redirect(to: to_do_user_path(conn, :show, to_do_user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", to_do_user: to_do_user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    to_do_user = ToDos.get_to_do_user!(id)
    {:ok, _to_do_user} = ToDos.delete_to_do_user(to_do_user)

    conn
    |> put_flash(:info, "To do user deleted successfully.")
 #   |> redirect(to: to_do_user_path(conn, :index))
  end
end
