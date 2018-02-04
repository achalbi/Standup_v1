defmodule StandupWeb.OrganizationController do
  use StandupWeb, :controller

 # plug :authorize
  plug Standup.Plugs.OrganizationAuthorizer

  alias Standup.Organizations
  alias Standup.Organizations.Organization

 # @actions [:edit, :delete]


  def index(conn, _params) do
    current_user = conn.assigns.current_user
    organizations = Organizations.list_organizations(current_user)
    if Enum.count(organizations) > 0 do
      conn
      |> redirect(to: organization_path(conn, :show, hd(organizations)))
    else
      render(conn, "index.html", organizations: organizations)
    end
  end

  def new(conn, _params) do
    changeset = Organizations.change_organization(%Organization{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"organization" => organization_params}) do
    case Organizations.create_organization(conn, organization_params) do
      {:ok, organization} ->
        conn
        |> put_flash(:info, "Organization created successfully.")
        |> redirect(to: organization_path(conn, :show, organization))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    organization = Organizations.get_organization!(id)
    members = Organizations.get_org_members(id)
    moderators = Organizations.get_org_moderators(id)
    teams = organization.teams
    render(conn, "show.html", organization: organization, members: members, moderators: moderators, teams: teams)
  end

  def edit(conn, %{"id" => id}) do
    organization = Organizations.get_organization!(id)
    changeset = Organizations.change_organization(organization)
    render(conn, "edit.html", organization: organization, changeset: changeset)
  end

  def update(conn, %{"id" => id, "organization" => organization_params}) do
    organization = Organizations.get_organization!(id)

    case Organizations.update_organization(organization, organization_params) do
      {:ok, organization} ->
        conn
        |> put_flash(:info, "Organization updated successfully.")
        |> redirect(to: organization_path(conn, :show, organization))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", organization: organization, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    organization = Organizations.get_organization!(id)
    {:ok, _organization} = Organizations.delete_organization(organization)

    conn
    |> put_flash(:info, "Organization deleted successfully.")
    |> redirect(to: organization_path(conn, :index))
  end

  # def authorize(%Plug.Conn{:private => %{:phoenix_action => action}} = conn, _default) when action in @actions do
	# 	organization = hd(conn.assigns.current_user.organizations)
	# 	if Organizations.is_org_moderator?(conn.assigns.current_user.id, organization.id) do
	# 		assign(conn, :authorized, true)
	# 	else
	# 		assign(conn, :authorized, false)
	# 		Standup.Plugs.Authorizer.unauthorized_user(conn)
	# 	end
	# end
end
