defmodule Standup.Organizations.UserTeam do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Organizations.{UserTeam, Team}
  alias Standup.Accounts.{User}


  schema "user_teams" do
    field :is_moderator, :boolean, default: false
    belongs_to :user, User
    belongs_to :team, Team


    timestamps()
  end

  @doc false
  def changeset(%UserTeam{} = user_team, attrs) do
    user_team
    |> cast(attrs, [:is_moderator])
    |> validate_required([:is_moderator])
  end
end
