defmodule Standup.Repo.Migrations.AlterTimestampsOfTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      modify :inserted_at, :timestamptz
      modify :updated_at, :timestamptz
    end
  end
end
