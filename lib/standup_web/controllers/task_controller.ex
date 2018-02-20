defmodule StandupWeb.TaskController do
  use StandupWeb, :controller

  plug Standup.Plugs.TaskAuthorizer

  alias Standup.StatusTrack
  alias Standup.StatusTrack.Task
  alias Standup.Organizations

  def index(conn, _params) do
    tasks = StatusTrack.list_tasks(conn)
    render(conn, "index.html", tasks: tasks)
  end
  
  def new(conn, params) do
    today = Date.utc_today
    current_user = conn.assigns.current_user
    organization = hd(current_user.organizations)
    teams = Organizations.get_teams_by_user_and_org(current_user.id, organization.id)
    if params["on_date"] do
      today = Timex.parse!(params["on_date"], "%Y-%m-%d", :strftime)  
    end
    changeset = StatusTrack.change_task(conn, %Task{tense: params["tense"]})
    render(conn, "new.html", changeset: changeset, today: today, teams: teams)
  end
  
  def create(conn, %{"task" => task_params}) do
    today = Date.utc_today
    if task_params["on_date"] != "" do
      today = task_params["on_date"]
      date = Timex.parse!(task_params["on_date"], "%Y-%m-%d", :strftime)
      task_params = Map.put(task_params, "on_date", date)
    end
    current_user = conn.assigns.current_user
    organization = hd(current_user.organizations)
    teams = Organizations.get_teams_by_user_and_org(current_user.id, organization.id)
    case StatusTrack.create_task(task_params) do
      {:ok, task} ->
        case StatusTrack.prepare_work_status_from_task(task, task_params) do
          {:ok, task} ->
            conn
            |> put_flash(:info, "Task created successfully.")
            |> redirect(to: task_path(conn, :show, task))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset, today: today, teams: teams)
        end
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, today: today, teams: teams)
    end
  end

  def show(conn, %{"id" => id}) do
    task = StatusTrack.get_task!(id)
    render(conn, "show.html", task: task)
  end

  def edit(conn, %{"id" => id}) do
    task = StatusTrack.get_task!(id)
    current_user = conn.assigns.current_user
    organization = hd(current_user.organizations)
    teams = Organizations.get_teams_by_user_and_org(current_user.id, organization.id)
    today = NaiveDateTime.to_date(task.on_date)
    changeset = StatusTrack.change_task(conn, task)
    render(conn, "edit.html", task: task, changeset: changeset, today: today, teams: teams)
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
    work_status_id = task.work_status.id
    {:ok, _task} = StatusTrack.delete_task(task)

    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: work_status_path(conn, :show, work_status_id))
  end
end
