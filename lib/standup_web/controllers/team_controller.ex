defmodule StandupWeb.TeamController do
  use StandupWeb, :controller

  alias Standup.Organizations
  alias Standup.Organizations.Team

  def index(conn, _params) do
    teams = Organizations.list_teams()
    render(conn, "index.html", teams: teams)
  end

  def new(conn, %{"organization_id" => organization_id}) do
    changeset = Organizations.change_team(%Team{organization_id: organization_id})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"team" => team_params}) do
    case Organizations.create_team(conn, team_params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team created successfully.")
        |> redirect(to: team_path(conn, :show, team))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Organizations.get_team!(id)
    members = Organizations.get_team_members(id)
    moderators = Organizations.get_team_moderators(id)
    users = Organizations.get_org_users_for_team(id)
    render(conn, "show.html", team: team, members: members, moderators: moderators, users: users)
  end

  def edit(conn, %{"id" => id}) do
    team = Organizations.get_team!(id)
    changeset = Organizations.change_team(team)
    render(conn, "edit.html", team: team, changeset: changeset)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Organizations.get_team!(id)

    case Organizations.update_team(team, team_params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team updated successfully.")
        |> redirect(to: team_path(conn, :show, team))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", team: team, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Organizations.get_team!(id)
    {:ok, _team} = Organizations.delete_team(team)

    conn
    |> put_flash(:info, "Team deleted successfully.")
    |> redirect(to: team_path(conn, :index))
  end

  def add_users do
    
  end
end
