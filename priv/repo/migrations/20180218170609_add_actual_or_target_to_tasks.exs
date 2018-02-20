defmodule Standup.Repo.Migrations.AddActualOrTargetToTasks do
  use Ecto.Migration

  def change do
    alter table("tasks") do
      add :tense, :string
    end
  end
end
