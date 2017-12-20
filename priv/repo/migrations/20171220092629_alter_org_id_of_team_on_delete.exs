defmodule Standup.Repo.Migrations.AlterOrgIdOfTeamOnDelete do
  use Ecto.Migration

  def change do
    drop constraint("teams", "teams_organization_id_fkey")
    alter table(:teams) do
      modify :organization_id, references(:organizations, on_delete: :delete_all)
    end
  end
end
