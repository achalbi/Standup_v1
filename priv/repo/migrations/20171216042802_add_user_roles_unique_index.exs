defmodule Standup.Repo.Migrations.AddUserRolesUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:user_roles, [:user_id, :role_id])
  end
end
