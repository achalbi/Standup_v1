defmodule Standup.Spreadsheets.Spreadsheet do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Spreadsheets.Spreadsheet
  alias Standup.Organizations.Organization

  @status [Active: "Active", "In-active": "In-active"]

  schema "spreadsheets" do
    field :spreadsheet_id, :string
    field :status, :string
    belongs_to :organization, Organization

    timestamps()
  end

  @doc false
  def changeset(%Spreadsheet{} = spreadsheet, attrs) do
    spreadsheet
    |> cast(attrs, [:spreadsheet_id, :organization_id, :status])
    |> validate_required([:spreadsheet_id])
  end

  def status do
    @status
  end
end
