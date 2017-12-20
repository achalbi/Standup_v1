defmodule Standup.Repo.Migrations.CreateUserTeams do
  use Ecto.Migration

  def change do
    create table(:user_teams) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :team_id, references(:teams, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_teams, [:user_id])
    create index(:user_teams, [:team_id])

    create unique_index(:user_teams, [:user_id, :team_id])
  end
end
