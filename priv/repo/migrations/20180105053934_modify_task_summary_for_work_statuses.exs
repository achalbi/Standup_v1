defmodule Standup.Repo.Migrations.ModifyTaskSummaryForWorkStatuses do
  use Ecto.Migration

  def change do
    alter table(:work_statuses) do
      modify :task_summary, :text
    end
  end
end
