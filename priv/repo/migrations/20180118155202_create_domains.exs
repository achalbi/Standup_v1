defmodule Standup.Repo.Migrations.CreateDomains do
  use Ecto.Migration

  def change do
    create table(:domains) do
      add :name, :string
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:domains, [:name])
    create index(:domains, [:organization_id])
  end
end
