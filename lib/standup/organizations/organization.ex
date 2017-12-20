defmodule Standup.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Organizations.{Organization, UserOrganization, Team}
  alias Standup.Accounts.User


  schema "organizations" do
    field :description, :string
    field :name, :string
    many_to_many :users, User, join_through: UserOrganization  
    has_many :teams, Team

    timestamps()
  end

  @doc false
  def changeset(%Organization{} = organization, attrs) do
    organization
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
