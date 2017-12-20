defmodule Standup.Repo.Migrations.AddIsModeratorToUserTeam do
  use Ecto.Migration

  def change do
    alter table(:user_teams) do
      add :is_moderator, :boolean, default: false, null: false
    end

  end
end
