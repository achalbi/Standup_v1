defmodule Standup.Repo.Migrations.CreateToDos do
  use Ecto.Migration

  def change do
    create table(:to_dos) do
      add :item_number, :string
      add :title, :text
      add :description, :text
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :status, :string
      add :ownership, :string
      add :list_type, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps(type: :timestamptz)
    end

    create index(:to_dos, [:user_id])
    create index(:to_dos, [:organization_id])
    create index(:to_dos, [:start_date])
    create index(:to_dos, [:end_date])
    create index(:to_dos, [:start_date, :end_date])
    create index(:to_dos, [:list_type])
  end
end
