defmodule Standup.ToDos.ToDo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.ToDos.ToDo
  alias Standup.Accounts.User
  alias Standup.Organizations.Organization

  @day [Today: "Today"]#, "This Week": "This Week"]
  @privacy [Public: "Public", Private: "Private"]
  @status_type ["To be Started": "To be Started", "In-Progress": "In-Progress", "Completed": "Completed", "Abandoned": "Abandoned", "Due": "Due"]
  @ownership_type ["Self": "Self", "Assigned": "Assigned", "Shared": "Shared"]

  schema "to_dos" do
    field :item_number, :string
    field :title, :string
    field :description, :string
    field :list_type, :string
    field :ownership, :string
    field :status, :string
    field :start_date, :naive_datetime
    field :end_date, :naive_datetime
    belongs_to :user, User
    belongs_to :organization, Organization

    timestamps()
  end

  @doc false
  def changeset(%ToDo{} = to_do, attrs) do
    to_do
    |> cast(attrs, [:item_number, :title, :description, :start_date, :end_date, :status, :ownership, :list_type, :user_id, :organization_id])
    |> validate_required([:title, :start_date, :end_date, :status, :ownership, :list_type])
  end

  def day do
    @day
  end

  def privacy do
    @privacy
  end

  def status_type do
    @status_type
  end

  def ownership_type do
    @ownership_type
  end
end
