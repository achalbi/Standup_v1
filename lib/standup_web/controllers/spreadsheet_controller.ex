defmodule StandupWeb.SpreadsheetController do
  use StandupWeb, :controller
  plug Standup.Plugs.SpreadsheetAuthorizer

  alias Standup.Spreadsheets
  alias Standup.Spreadsheets.Spreadsheet

  def index(conn, %{"organization_id" => organization_id}) do
    spreadsheet = Spreadsheets.list_spreadsheets(organization_id)
    render(conn, "index.html", spreadsheets: [spreadsheet])
  end

  def new(conn, %{"organization_id" => organization_id}) do
    changeset = Spreadsheets.change_spreadsheet(%Spreadsheet{})
    render(conn, "new.html", changeset: changeset, organization_id: organization_id)
  end

  def create(conn, %{"spreadsheet" => spreadsheet_params}) do
    case Spreadsheets.create_spreadsheet(spreadsheet_params) do
      {:ok, spreadsheet} ->
        spreadsheet = Spreadsheets.get_spreadsheet!(spreadsheet.id)
        conn
        |> put_flash(:info, "Spreadsheet created successfully.")
        |> redirect(to: organization_spreadsheet_path(conn, :show, spreadsheet.organization, spreadsheet))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    spreadsheet = Spreadsheets.get_spreadsheet!(id)
    render(conn, "show.html", spreadsheet: spreadsheet)
  end

  def edit(conn, %{"id" => id}) do
    spreadsheet = Spreadsheets.get_spreadsheet!(id)
    changeset = Spreadsheets.change_spreadsheet(spreadsheet)
    render(conn, "edit.html", spreadsheet: spreadsheet, changeset: changeset, organization_id: spreadsheet.organization_id)
  end

  def update(conn, %{"id" => id, "spreadsheet" => spreadsheet_params}) do
    spreadsheet = Spreadsheets.get_spreadsheet!(id)

    case Spreadsheets.update_spreadsheet(spreadsheet, spreadsheet_params) do
      {:ok, spreadsheet} ->
        conn
        |> put_flash(:info, "Spreadsheet updated successfully.")
        |> redirect(to: organization_spreadsheet_path(conn, :show, spreadsheet.organization, spreadsheet))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", spreadsheet: spreadsheet, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "organization_id" => organization_id}) do
    spreadsheet = Spreadsheets.get_spreadsheet!(id)
    {:ok, _spreadsheet} = Spreadsheets.delete_spreadsheet(spreadsheet)

    conn
    |> put_flash(:info, "Spreadsheet deleted successfully.")
    |> redirect(to: organization_path(conn, :show, organization_id))
  end
end
