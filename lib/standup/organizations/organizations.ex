defmodule Standup.Organizations do
  @moduledoc """
  The Organizations context.
  """

  require IEx

  import Ecto.Query, warn: false
  alias Standup.Repo
  alias Standup.Accounts.User

  alias Standup.Organizations.{Organization, UserOrganization, UserTeam, Team}

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id) |> Repo.preload([:users, :teams])

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(conn, attrs \\ %{}) do
    current_user = conn.assigns.current_user
    result = %Organization{}
    |> Organization.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:users, [current_user])
    |> Repo.insert()

    case result do
      {:ok , organization} -> 
        attrs = %{is_moderator: true}
        UserOrganization
        |> Repo.get_by(organization_id: organization.id)
        |> UserOrganization.changeset(attrs)
        |> Repo.update() 
    end
    result
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{source: %Organization{}}

  """
  def change_organization(%Organization{} = organization) do
    Organization.changeset(organization, %{})
  end

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id) |> Repo.preload(:organization)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(conn, attrs \\ %{}) do
    current_user = conn.assigns.current_user
    org = Organization |> Repo.get(attrs["organization_id"])
    result = %Team{}
    |> Team.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:organization, org)
    |> Ecto.Changeset.put_assoc(:users, [current_user])
    |> Repo.insert()

    case result do
      {:ok , team} -> 
        attrs = %{is_moderator: true}
        UserTeam
        |> Repo.get_by(team_id: team.id)
        |> UserTeam.changeset(attrs)
        |> Repo.update() 
    end
    result
  end
  
  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{source: %Team{}}

  """
  def change_team(%Team{} = team) do
    Team.changeset(team, %{})
  end


  def get_org_members(org_id) do
    query = from uo in UserOrganization,
    join: u in User,
    where: uo.user_id == u.id,
    where: uo.is_moderator == false and uo.organization_id == ^org_id, 
    select: u
    
    Repo.all(query)

  end

  def get_org_moderators(org_id) do
    query = from uo in UserOrganization,
    join: u in User,
    where: uo.user_id == u.id,
    where: uo.is_moderator == true and uo.organization_id == ^org_id, 
    select: u
    
    Repo.all(query)
  end

    def get_team_members(team_id) do
    query = from ut in UserTeam,
    join: u in User,
    where: ut.user_id == u.id,
    where: ut.is_moderator == false and ut.team_id == ^team_id, 
    select: u
    
    Repo.all(query)

  end

  def get_team_moderators(team_id) do
    query = from ut in UserTeam,
    join: u in User,
    where: ut.user_id == u.id,
    where: ut.is_moderator == true and ut.team_id == ^team_id, 
    select: u
    
    Repo.all(query)
  end
end
