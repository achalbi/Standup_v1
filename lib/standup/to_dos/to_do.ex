defmodule Standup.ToDos.ToDo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.ToDos.ToDo
  alias Standup.Accounts.User
  alias Standup.Organizations.Organization


  schema "to_dos" do
    field :description, :string
    field :end_date, :utc_datetime
    field :item_number, :string
    field :list_type, :string
    field :ownership, :string
    field :start_date, :utc_datetime
    field :status, :string
    field :title, :string
    belongs_to :user, User
    belongs_to :organization, Organization

    timestamps()
  end

  @doc false
  def changeset(%ToDo{} = to_do, attrs) do
    to_do
    |> cast(attrs, [:item_number, :title, :description, :start_date, :end_date, :status, :ownership, :list_type])
    |> validate_required([:item_number, :title, :description, :start_date, :end_date, :status, :ownership, :list_type])
  end
end
