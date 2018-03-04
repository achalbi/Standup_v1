defmodule StandupWeb.TaskController do
  use StandupWeb, :controller

  plug Standup.Plugs.TaskAuthorizer
  plug :task_date_validator
  require IEx

  alias Standup.StatusTrack
  alias Standup.StatusTrack.Task
  alias Standup.Organizations
  alias Standup.ToDos

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
    status = cond do
      (params["tense"] == "Target") || (params["tense"] == "Next Target")  -> "Yet to Start"
      true -> "Completed"      
    end
    tense = if (params["tense"] == "Target") || (params["tense"] == "Next Target"), do: "Target"
    changeset = StatusTrack.change_task(conn, %Task{tense: tense, status: status})
    render(conn, (if params["tense"] == "Next Target", do: "new_next_target.html", else: "new.html"), changeset: changeset, today: today, teams: teams, work_status_type_id: params["work_status_type_id"])
  end
  
  def create(conn, %{"task" => task_params} = params) do
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
            StatusTrack.update_key_result_area_accountability(task.work_status.id)
            conn
            |> put_flash(:info, "Task created successfully.")
            |> redirect(to: task_path(conn, :show, task))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset, today: today, teams: teams, work_status_type_id: params["work_status_type_id"])
        end
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, today: today, teams: teams, work_status_type_id: params["work_status_type_id"])
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
        StatusTrack.update_key_result_area_accountability(task.work_status.id)
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
    work_status_type_id = task.work_status.work_status_type_id
    {:ok, _task} = StatusTrack.delete_task(task)
    StatusTrack.update_key_result_area_accountability(work_status_id)
    
    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: work_status_path(conn, :show, work_status_id, work_status_type_id: work_status_type_id))
  end

  def export_to_do_to_tasks(conn, %{"to_do_id" => to_do_id}) do
    to_do = ToDos.get_to_do!(to_do_id)
    task_number = to_do.item_number
    title = to_do.title
    notes = to_do.description
    status = to_do.status
    on_date = NaiveDateTime.to_date(to_do.end_date)
    tense = "Target"
    user_id = to_do.user_id
    
    current_user = conn.assigns.current_user
    organization = hd(current_user.organizations)
    organization = Organizations.get_organization!(organization.id)
    work_status_type_id = hd(organization.work_status_types).id

    teams = Organizations.get_teams_by_user_and_org(user_id, to_do.organization_id)
    changeset = StatusTrack.change_task(conn, %Task{task_number: task_number, title: title, notes: notes, tense: tense, status: status, on_date: on_date, user_id: user_id})
    render(conn, "new_next_target.html", changeset: changeset, today: on_date, teams: teams, work_status_type_id: work_status_type_id)
  end

  defp task_date_validator(%Plug.Conn{:private => %{:phoenix_action => :new}, :params => %{"on_date" => on_date, "tense" => tense}} = conn, _) do
    if tense == "Actual" do
      today = Date.utc_today
      params_date = Timex.parse!(on_date, "%Y-%m-%d", :strftime)  
      date  = NaiveDateTime.to_date(params_date)
      if date > today do
        assign(conn, :authorized, false)
        Standup.Plugs.Authorizer.unauthorized_user(conn)
		  else
        assign(conn, :authorized, true)
      end 
    else
        assign(conn, :authorized, true)
    end
  end
  defp task_date_validator(conn, _), do: conn
end
