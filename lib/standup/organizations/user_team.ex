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
    |> cast(attrs, [:is_moderator, :team_id, :user_id])
    |> validate_required([:is_moderator, :team_id, :user_id])
    |> unique_constraint(:user_id, name: :user_teams_user_id_team_id_index)
  end
end
