defmodule Standup.Repo.Migrations.AddStatusToSpreadsheet do
  use Ecto.Migration

  def change do
    alter table(:spreadsheets) do
      add :status, :string
    end
  end
end
