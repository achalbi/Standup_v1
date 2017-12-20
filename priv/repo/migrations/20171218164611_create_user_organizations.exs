defmodule Standup.Repo.Migrations.CreateUserOrganizations do
  use Ecto.Migration

  def change do
    create table(:user_organizations) do
      add :is_moderator, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :organization_id, references(:organizations, on_delete: :nothing)

      timestamps()
    end

    create index(:user_organizations, [:user_id])
    create index(:user_organizations, [:organization_id])
  end
end
