defmodule Standup.Repo.Migrations.CreateKeyResultAreas do
  use Ecto.Migration

  def change do
    create table(:key_result_areas) do
      add :accountability, :text
      add :ownership, :text
      add :productivity, :float
      add :skill, :text
      add :effective_communication, :boolean, default: false, null: false
      add :impediments, :text
      add :work_status_id, references(:work_statuses, on_delete: :delete_all)

      timestamps()
    end
  end
end
