defmodule Standup.Repo.Migrations.AddSheetRowIdForWorkStatuses do
  use Ecto.Migration

  def change do
    alter table(:work_statuses) do
      add :sheet_row_id, :integer
    end

    create index(:work_statuses, [:sheet_row_id])
  end
end
