defmodule Standup.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :task_number, :string
      add :title, :string
      add :url, :string
      add :status, :string
      add :notes, :text
      add :on_date, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)
      add :work_status_id, references(:work_statuses, on_delete: :nothing)

      timestamps()
    end

    create index(:tasks, [:user_id])
    create index(:tasks, [:work_status_id])
  end
end
