defmodule Standup.Repo.Migrations.CreateSpreadsheets do
  use Ecto.Migration

  def change do
    create table(:spreadsheets) do
      add :spreadsheet_id, :string
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:spreadsheets, [:organization_id])
  end
end
