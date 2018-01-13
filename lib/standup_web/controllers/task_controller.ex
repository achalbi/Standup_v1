defmodule StandupWeb.TaskController do
  use StandupWeb, :controller

  require IEx
  alias Standup.StatusTrack
  alias Standup.StatusTrack.Task

  def index(conn, _params) do
    tasks = StatusTrack.list_tasks()
    render(conn, "index.html", tasks: tasks)
  end

  def new(conn, _params) do
    today = Date.utc_today
    changeset = StatusTrack.change_task(conn, %Task{})
    render(conn, "new.html", changeset: changeset, today: today)
  end
  
  def create(conn, %{"task" => task_params}) do
    today = Date.utc_today
    date = Timex.parse!(task_params["on_date"], "%Y-%m-%d", :strftime)
    task_params = Map.put(task_params, "on_date", date)
    case StatusTrack.create_task(task_params) do
      {:ok, task} ->
        case StatusTrack.prepare_work_status_from_task(task, task_params) do
          {:ok, task} ->
            conn
            |> put_flash(:info, "Task created successfully.")
            |> redirect(to: task_path(conn, :show, task))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset, today: today)
        end
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, today: today)
    end
  end

  def show(conn, %{"id" => id}) do
    task = StatusTrack.get_task!(id)
    render(conn, "show.html", task: task)
  end

  def edit(conn, %{"id" => id}) do
    task = StatusTrack.get_task!(id)
    today = task.on_date
    changeset = StatusTrack.change_task(conn, task)
    render(conn, "edit.html", task: task, changeset: changeset, today: today)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = StatusTrack.get_task!(id)

    case StatusTrack.update_task(task, task.work_status, task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task updated successfully.")
        |> redirect(to: task_path(conn, :show, task))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", task: task, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = StatusTrack.get_task!(id)
    {:ok, _task} = StatusTrack.delete_task(task)

    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: task_path(conn, :index))
  end
end
