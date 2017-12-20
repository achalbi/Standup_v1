defmodule Standup.Organizations.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Organizations.{Team, Organization, UserTeam}
  alias Standup.Accounts.User

  schema "teams" do
    field :description, :string
    field :name, :string
    belongs_to :organization, Organization 
    many_to_many :users, User, join_through: UserTeam 

    timestamps()
  end

  @doc false
  def changeset(%Team{} = team, attrs) do
    team
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
