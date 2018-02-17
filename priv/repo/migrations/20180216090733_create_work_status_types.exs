defmodule Standup.Repo.Migrations.CreateWorkStatusTypes do
  use Ecto.Migration

  def change do
    create table(:work_status_types) do
      add :name, :string
      add :description, :text
      add :period, :integer
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps()
    end

  end
end
