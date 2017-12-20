defmodule Standup.Repo.Migrations.AlterUserIdOrgIdOfUserOrgOnDelete do
  use Ecto.Migration

  def change do
    drop constraint("user_organizations", "user_organizations_user_id_fkey")
    drop constraint("user_organizations", "user_organizations_organization_id_fkey")
    alter table(:user_organizations) do
      modify :user_id, references(:users, on_delete: :delete_all)
      modify :organization_id, references(:organizations, on_delete: :delete_all)
    end
  end
end
