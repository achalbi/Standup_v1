defmodule StandupWeb.DomainController do
  use StandupWeb, :controller

  plug Standup.Plugs.DomainAuthorizer

  alias Standup.Organizations
  alias Standup.Organizations.Domain

  def index(conn, params) do
    org_id = params["organization_id"]
    org = Organizations.get_organization_with_domains!(org_id)
    domains = Organizations.list_domains(org_id)
    render(conn, "index.html", domains: domains, org: org)
  end

  def new(conn, params) do
    org = Organizations.get_organization_with_domains!(params["organization_id"])
    changeset = Organizations.change_domain(%Domain{})
    render(conn, "new.html", changeset: changeset, org: org)
  end

  def create(conn, %{"domain" => domain_params, "organization_id" => org_id}) do
    org = Organizations.get_organization_with_domains!(org_id)
    
    case Organizations.create_domain(domain_params, org) do
      {:ok, _domain} ->
        conn
        |> put_flash(:info, "Domain created successfully.")
        |> redirect(to: organization_domain_path(conn, :index, org_id))
       # |> redirect(to: organization_domain_path(conn, :show, org, domain))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, org: org)
    end
  end
      
  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    domain = Organizations.get_domain!(id)
    render(conn, "show.html", domain: domain, org_id: org_id)
  end
      
  
  def edit(conn, %{"organization_id" => org_id, "id" => id}) do
    org = Organizations.get_organization_with_domains!(org_id)
    domain = Organizations.get_domain!(id)
    changeset = Organizations.change_domain(domain)
    render(conn, "edit.html", domain: domain, changeset: changeset, org: org)
  end

  def update(conn, %{"id" => id, "domain" => domain_params, "organization_id" => org_id}) do
    domain = Organizations.get_domain!(id)

    case Organizations.update_domain(domain, domain_params) do
      {:ok, domain} ->
        conn
        |> put_flash(:info, "Domain updated successfully.")
        |> redirect(to: organization_domain_path(conn, :show, org_id, domain))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", domain: domain, changeset: changeset, org_id: org_id)
    end
  end

  def delete(conn, %{"organization_id" => org_id, "id" => id}) do
    domain = Organizations.get_domain!(id)
    {:ok, _domain} = Organizations.delete_domain(domain)

    conn
    |> put_flash(:info, "Domain deleted successfully.")
    |> redirect(to: organization_domain_path(conn, :index, org_id))
  end
end
