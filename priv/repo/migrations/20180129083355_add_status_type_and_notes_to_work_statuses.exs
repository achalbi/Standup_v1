defmodule Standup.Repo.Migrations.AddStatusTypeAndNotesToWorkStatuses do
  use Ecto.Migration

  def change do
    alter table(:work_statuses) do
      add :status_type, :string
      add :notes, :text
    end

    create index("work_statuses", [:status_type])
  end
end
