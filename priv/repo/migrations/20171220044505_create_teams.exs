defmodule Standup.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :description, :string
      add :organization_id, references(:organizations, on_delete: :nothing)

      timestamps()
    end

    create index(:teams, [:organization_id])
  end
end
