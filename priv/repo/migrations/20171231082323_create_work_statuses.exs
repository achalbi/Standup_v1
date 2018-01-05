defmodule Standup.Repo.Migrations.CreateWorkStatuses do
  use Ecto.Migration

  def change do
    create table(:work_statuses) do
      add :user_name, :string
      add :task_summary, :string
      add :on_date, :date

      timestamps(type: :timestamptz)
    end

  end
end
