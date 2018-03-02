defmodule StandupWeb.WorkStatusController do
  use StandupWeb, :controller

  plug Standup.Plugs.WorkStatusAuthorizer
  
  alias Standup.StatusTrack
  alias Standup.StatusTrack.WorkStatus
  alias Standup.Organizations

  def index(conn, params) do
    work_status_type_id = params["work_status_type_id"]
    work_status_type = StatusTrack.get_work_status_type!(work_status_type_id)
    work_statuses = StatusTrack.list_work_statuses(conn)
    render(conn, "index.html", work_statuses: work_statuses, work_status_type: work_status_type)
  end

  def new(conn, params) do
    today = unless params["on_date"] == nil || params["on_date"] == "", do: Timex.parse!(params["on_date"], "%Y-%m-%d", :strftime), else: Date.utc_today
    current_user = conn.assigns.current_user
    organization = hd(current_user.organizations)
    organization = Organizations.get_organization!(organization.id)
    work_status_type_id = params["work_status_type_id"] || hd(organization.work_status_types).id
    work_status_type = StatusTrack.get_work_status_type!(work_status_type_id)
    case StatusTrack.get_work_status_by_date_and_user_id(today, current_user.id) do
      %WorkStatus{} = work_status -> 
        changeset = StatusTrack.change_work_status(work_status)
        render(conn, "edit.html", work_status: work_status, changeset: changeset, today: today, work_status_type_id: work_status_type_id, work_status_type: work_status_type, organization: organization)
      _ -> 
        changeset = StatusTrack.change_work_status(%WorkStatus{user_id: current_user.id, organization_id: organization.id})
        render(conn, "new.html", changeset: changeset, today: today, organization: organization, work_status_type_id: work_status_type_id, work_status_type: work_status_type, organization: organization)
    end
    
  end

  def create(conn, %{"work_status" => work_status_params}) do
    today = Timex.parse!(work_status_params["on_date"], "%Y-%m-%d", :strftime)
    work_status_type_id = work_status_params["work_status_type_id"] 
    work_status_type = StatusTrack.get_work_status_type!(work_status_type_id)
    case StatusTrack.create_work_status(work_status_params) do
      {:ok, work_status} ->
        conn
        |> put_flash(:info, "Work status created successfully.")
        |> redirect(to: work_status_path(conn, :show, work_status, work_status_type_id: work_status_type_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, today: today, work_status_type: work_status_type)
    end
  end

  def show(conn, %{"id" => id}) do
    work_status = StatusTrack.get_work_status!(id)
    comments = StatusTrack.list_comments(id)
    #current_user = conn.assigns.current_user
    #organization = hd(current_user.organizations)
    #organization = Organizations.get_organization!(organization.id)
    #work_status_type_id = params["work_status_type_id"] || hd(organization.work_status_types).id
    work_status_type = StatusTrack.get_work_status_type!(work_status.work_status_type_id)
    actual_tasks = StatusTrack.get_task_by_work_status_and_tense(id, "Actual")
    target_tasks = StatusTrack.get_task_by_work_status_and_tense(id, "Target")
    next_target_tasks = StatusTrack.get_task_by_work_status_and_next_target(id)
    render(conn, "show.html", work_status: work_status, work_status_type: work_status_type, actual_tasks: actual_tasks, target_tasks: target_tasks, next_target_tasks: next_target_tasks, comments: comments)
  end

  def edit(conn, %{"id" => id} = params) do
    work_status = StatusTrack.get_work_status!(id)
    today = work_status.on_date
    organization = hd(conn.assigns.current_user.organizations)
    organization = Organizations.get_organization!(organization.id)
    work_status_type_id = params["work_status_type_id"]
    work_status_type = StatusTrack.get_work_status_type!(work_status_type_id)
    changeset = StatusTrack.change_work_status(work_status)
    render(conn, "edit.html", work_status: work_status, changeset: changeset, today: today, work_status_type: work_status_type, organization: organization)
  end

  def update(conn, %{"id" => id, "work_status" => work_status_params} = params) do
    work_status = StatusTrack.get_work_status!(id)
    work_status_type_id = params["work_status_type_id"]
    work_status_type = StatusTrack.get_work_status_type!(work_status_type_id)
    case StatusTrack.update_work_status_with_tasks(work_status, work_status_params) do
      {:ok, work_status} ->
        conn
        |> put_flash(:info, "Work status updated successfully.")
        |> redirect(to: work_status_path(conn, :show, work_status, work_status_type_id: work_status_type_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", work_status: work_status, changeset: changeset, work_status_type: work_status_type)
    end
  end

  def delete(conn, %{"id" => id} = params) do
    work_status = StatusTrack.get_work_status!(id)
    {:ok, _work_status} = StatusTrack.delete_work_status(work_status)
    work_status_type_id = params["work_status_type_id"]
    conn
    |> put_flash(:info, "Work status deleted successfully.")
    |> redirect(to: work_status_path(conn, :index, work_status_type_id: work_status_type_id))
  end

  def team_work_statuses(conn, params) do
    org = hd(conn.assigns.current_user.organizations)
    teams = Organizations.get_teams_by_user_and_org(conn.assigns.current_user.id, org.id)
    work_status_type_id = params["work_status_type_id"]
    work_status_type = StatusTrack.get_work_status_type!(work_status_type_id)
    if Enum.count(teams) > 0 do
      case params do
        %{"team_id" => team_id, "on_date" => on_date} ->
          date = Timex.parse!(on_date, "%Y-%m-%d", :strftime)
          team = Organizations.get_team!(team_id)
        _ ->
          {:ok, time} = Time.new(0, 0, 0, 0)
          {:ok, date} = NaiveDateTime.new(Date.utc_today, time)
          team = hd(teams)
      end
      work_statuses = StatusTrack.list_work_statuses_by_team_and_date(team, date)
      render(conn, "team_index.html", work_statuses: work_statuses, teams: teams, date: date, team: team, work_status_type: work_status_type)
    else
      conn
      |> put_flash(:error, "Please join a Team")
      |> render("team_index.html", teams: teams, work_status_type: work_status_type)

    end
  end
end
