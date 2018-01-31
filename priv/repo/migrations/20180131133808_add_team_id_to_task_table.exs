defmodule Standup.Repo.Migrations.AddTeamIdToTaskTable do
  use Ecto.Migration

  def change do
    alter table("tasks") do
      add :team_id, references(:teams, on_delete: :nothing), null: false
    end
  end
end
