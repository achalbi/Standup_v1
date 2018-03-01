defmodule Standup.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Organizations.{Organization, UserOrganization, Team, Domain}
  alias Standup.Accounts.User
  alias Standup.StatusTrack.WorkStatus
  alias Standup.StatusTrack.WorkStatusType
  alias Standup.Spreadsheets.Spreadsheet


  schema "organizations" do
    field :description, :string
    field :name, :string
    many_to_many :users, User, join_through: UserOrganization  
    has_many :teams, Team
    has_many :work_statuses, WorkStatus
    has_many :work_status_types, WorkStatusType
    has_many :domains, Domain
    has_one :spreadsheet, Spreadsheet

    timestamps()
  end

  @doc false
  def changeset(%Organization{} = organization, attrs) do
    organization
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
