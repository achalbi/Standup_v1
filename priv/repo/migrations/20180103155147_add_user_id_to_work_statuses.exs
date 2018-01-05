defmodule Standup.Repo.Migrations.AddUserIdToWorkStatuses do
  use Ecto.Migration

  def change do
    alter table(:work_statuses) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:work_statuses, [:user_id])
  end
end
