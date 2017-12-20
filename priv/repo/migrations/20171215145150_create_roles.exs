defmodule Standup.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :key, :string
      add :name, :string
      add :description, :text

      timestamps()
    end

    create index(:roles, [:key])
  end
end
