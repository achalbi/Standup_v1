defmodule Standup.Repo.Migrations.AddUserEmailForWorkStatuses do
  use Ecto.Migration

  def change do
    alter table(:work_statuses) do
      add :user_email, :string
    end

    create index(:work_statuses, [:user_email])
  end
end
