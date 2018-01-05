defmodule Standup.Repo.Migrations.AlterUserIdWorkStatusIdOfTasksOnDelete do
  use Ecto.Migration

  def change do
    drop constraint("tasks", "tasks_user_id_fkey")
    drop constraint("tasks", "tasks_work_status_id_fkey")
    alter table(:tasks) do
      modify :user_id, references(:users, on_delete: :delete_all)
      modify :work_status_id, references(:work_statuses, on_delete: :delete_all)
    end
  end
end
