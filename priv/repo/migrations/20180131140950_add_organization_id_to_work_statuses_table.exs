defmodule Standup.Repo.Migrations.AddOrganizationIdToWorkStatusesTable do
  use Ecto.Migration

  def change do
    alter table("work_statuses") do
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
    end
  end
end
