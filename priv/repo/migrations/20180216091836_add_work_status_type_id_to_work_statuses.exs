defmodule Standup.Repo.Migrations.AddWorkStatusTypeIdToWorkStatuses do
  use Ecto.Migration

  def change do
    alter table("work_statuses") do
      add :work_status_type_id, references(:work_status_types, on_delete: :nothing)
    end
  end
end
