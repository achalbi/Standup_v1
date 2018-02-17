defmodule StandupWeb.WorkStatusController do
  use StandupWeb, :controller

  plug Standup.Plugs.WorkStatusAuthorizer
  
  alias Standup.StatusTrack
  alias Standup.StatusTrack.WorkStatus
  alias Standup.Organizations


  def index(conn, _params) do
    work_statuses = StatusTrack.list_work_statuses(conn)
    render(conn, "index.html", work_statuses: work_statuses)
  end

  def new(conn, params) do
    today = unless params["on_date"] == nil || params["on_date"] == "", do: Timex.parse!(params["on_date"], "%Y-%m-%d", :strftime), else: Date.utc_today
    current_user = conn.assigns.current_user
    organization = hd(current_user.organizations)
    organization = Organizations.get_organization!(organization.id)
    work_status_type_id = params["work_status_type"] || hd(organization.work_status_types).id
    case StatusTrack.get_work_status_by_date_and_user_id(today, current_user.id) do
      %WorkStatus{} = work_status -> 
        changeset = StatusTrack.change_work_status(work_status)
        render(conn, "edit.html", work_status: work_status, changeset: changeset, today: today)
      _ -> 
        changeset = StatusTrack.change_work_status(%WorkStatus{user_id: current_user.id, organization_id: organization.id})
        render(conn, "new.html", changeset: changeset, today: today, organization: organization, work_status_type_id: work_status_type_id)
    end
    
  end

  def create(conn, %{"work_status" => work_status_params}) do
    today = Timex.parse!(work_status_params["on_date"], "%Y-%m-%d", :strftime)
    case StatusTrack.create_work_status(work_status_params) do
      {:ok, work_status} ->
        conn
        |> put_flash(:info, "Work status created successfully.")
        |> redirect(to: work_status_path(conn, :show, work_status))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, today: today)
    end
  end

  def show(conn, %{"id" => id}) do
    work_status = StatusTrack.get_work_status!(id)
    render(conn, "show.html", work_status: work_status)
  end

  def edit(conn, %{"id" => id}) do
    work_status = StatusTrack.get_work_status!(id)
    today = work_status.on_date
    changeset = StatusTrack.change_work_status(work_status)
    render(conn, "edit.html", work_status: work_status, changeset: changeset, today: today)
  end

  def update(conn, %{"id" => id, "work_status" => work_status_params}) do
    work_status = StatusTrack.get_work_status!(id)

    case StatusTrack.update_work_status_with_tasks(work_status, work_status_params) do
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

  def team_work_statuses(conn, params) do
    org = hd(conn.assigns.current_user.organizations)
    teams = Organizations.get_teams_by_user_and_org(conn.assigns.current_user.id, org.id)
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
      render(conn, "team_index.html", work_statuses: work_statuses, teams: teams, date: date, team: team)
    else
      conn
      |> put_flash(:error, "Please join a Team")
      |> render("team_index.html", teams: teams)

    end
  end
end
