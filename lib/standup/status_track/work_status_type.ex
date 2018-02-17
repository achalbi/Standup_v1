defmodule Standup.StatusTrack.WorkStatusType do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.StatusTrack.WorkStatusType
  alias Standup.Organizations.Organization


  schema "work_status_types" do
    field :description, :string
    field :name, :string
    field :period, :integer
    belongs_to :organization, Organization

    timestamps()
  end

  @doc false
  def changeset(%WorkStatusType{} = work_status_type, attrs) do
    work_status_type
    |> cast(attrs, [:name, :description, :period, :organization_id])
    |> validate_required([:name, :period])
  end
end
