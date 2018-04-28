defmodule Standup.Organizations do
  @moduledoc """
  The Organizations context.
  """

  require IEx

  import Ecto.Query, warn: false
  alias Standup.Repo
  alias Standup.Accounts.User

  alias Standup.Organizations.Domain
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

  def list_organizations(user) do
    query = from o in Organization,
    join:  u in assoc(o, :users), on: u.id == ^user.id
    Repo.all(query)
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
  def get_organization!(id), do: Repo.get!(Organization, id) |> Repo.preload([[users: :photo], :teams, :domains, :work_status_types, :spreadsheet])

  def get_organization_with_domains!(id), do: Repo.get!(Organization, id) |> Repo.preload([:domains])
  
  def get_organization_from_domain!(domain_name) do
    domain = Repo.get_by(Domain, name: domain_name) |> Repo.preload([:organization])
    if domain, do: domain.organization, else: nil
  end

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
  def get_team!(id), do: Repo.get!(Team, id) |> Repo.preload([:organization, :users])

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
         set_as_moderator(team, current_user)
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

  def add_users_to_team(team, user) do
    attrs = %{"team_id" => team.id, "user_id" => user.id}
    %UserTeam{}
    |> UserTeam.changeset(attrs)
    |> Repo.insert() 
  end

  def remove_users_from_team(team, user) do
    if get_user_team(team,user) do
        UserTeam
        |> Repo.get_by(team_id: team.id, user_id: user.id)
        |> Repo.delete() 
    else
      {:error, "user doesn't exist"}  
    end
  end

  def get_user_team(team,user) do
    UserTeam
    |> Repo.get_by(team_id: team.id, user_id: user.id)
  end

  def is_team_moderator?(team,user) do
    ut = get_user_team(team,user)
    if ut, do: ut.is_moderator, else: nil
  end

  def set_as_moderator(team,user) do
    attrs = %{is_moderator: true}
    get_user_team(team,user)
    |> UserTeam.changeset(attrs)
    |> Repo.update() 
  end

  def set_as_member(team,user) do
    attrs = %{is_moderator: false}
    get_user_team(team,user)
    |> UserTeam.changeset(attrs)
    |> Repo.update()
  end

  def is_current_user_moderator?(conn) do
    organization = hd(conn.assigns.current_user.organizations)
    is_org_moderator?(conn.assigns.current_user.id, organization.id)
  end

  def is_org_moderator?(user_id, org_id) do
    uo = UserOrganization
    |> Repo.get_by(organization_id: org_id, user_id: user_id)
    uo.is_moderator
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
    
    users = Repo.all(query)
    users |> Repo.preload(:photo)
  end

  def get_team_moderators(team_id) do
    query = from ut in UserTeam,
    join: u in User,
    where: ut.user_id == u.id,
    where: ut.is_moderator == true and ut.team_id == ^team_id,
    select: u
    
    users = Repo.all(query)
    users |> Repo.preload(:photo)
  end

  def get_org_users(org_id) do
    query = from uo in UserOrganization,
    join: u in User,
    where: uo.user_id == u.id and uo.organization_id == ^org_id, 
    select: u
    
    Repo.all(query)
  end

  def get_team_users(team_id) do
    query = from ut in UserTeam,
    join: u in User,
    where: ut.user_id == u.id,
    where: ut.team_id == ^team_id,
    select: u
    
    users = Repo.all(query)
    users |> Repo.preload(:photo)
  end
  
  def get_org_users_for_team(team_id)  do
    team = Repo.get!(Team, team_id) |> Repo.preload([:organization, :users])
    org_id = team.organization.id
    team_users = Enum.map(team.users, fn(user) -> user.id end)

    query = from uo in UserOrganization,
    join: u in User,
    where: uo.user_id == u.id and uo.organization_id == ^org_id, 
    where: uo.user_id not in ^team_users,
    select: u
    
    Repo.all(query)
    |> Repo.preload(:photo)
  end

  def get_teams_by_user_and_org(user_id, org_id) do
    query = from ut in UserTeam,
    join: t in Team,
    where: ut.team_id == t.id and ut.user_id == ^user_id and t.organization_id == ^org_id, 
    select: t

    Repo.all(query)
  end

  @doc """
  Returns the list of domains.

  ## Examples

      iex> list_domains()
      [%Domain{}, ...]

  """
  def list_domains(org_id) do
    domains = from d in Domain,
    where: d.organization_id == ^org_id
    
    Repo.all(domains)
  end

  @doc """
  Gets a single domain.

  Raises `Ecto.NoResultsError` if the Domain does not exist.

  ## Examples

      iex> get_domain!(123)
      %Domain{}

      iex> get_domain!(456)
      ** (Ecto.NoResultsError)

  """
  def get_domain!(id), do: Repo.get!(Domain, id)

  @doc """
  Creates a domain.

  ## Examples

      iex> create_domain(%{field: value})
      {:ok, %Domain{}}

      iex> create_domain(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_domain(attrs \\ %{}, org) do
    %Domain{}
    |> Domain.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:organization, org)
    |> Repo.insert()
  end

  @doc """
  Updates a domain.

  ## Examples

      iex> update_domain(domain, %{field: new_value})
      {:ok, %Domain{}}

      iex> update_domain(domain, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_domain(%Domain{} = domain, attrs) do
    domain
    |> Domain.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Domain.

  ## Examples

      iex> delete_domain(domain)
      {:ok, %Domain{}}

      iex> delete_domain(domain)
      {:error, %Ecto.Changeset{}}

  """
  def delete_domain(%Domain{} = domain) do
    Repo.delete(domain)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking domain changes.

  ## Examples

      iex> change_domain(domain)
      %Ecto.Changeset{source: %Domain{}}

  """
  def change_domain(%Domain{} = domain) do
    Domain.changeset(domain, %{})
  end
end
