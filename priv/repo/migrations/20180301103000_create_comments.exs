defmodule Standup.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :work_status_id, references(:work_statuses, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:comments, [:work_status_id])
    create index(:comments, [:user_id])
  end
end
