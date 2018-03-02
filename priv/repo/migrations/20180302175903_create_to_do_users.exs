defmodule Standup.Repo.Migrations.CreateToDoUsers do
  use Ecto.Migration

  def change do
    create table(:to_do_users) do
      add :to_do_id, references(:to_dos, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:to_do_users, [:to_do_id])
    create index(:to_do_users, [:user_id])
    create index(:to_do_users, [:to_do_id, :user_id])
  end
end
