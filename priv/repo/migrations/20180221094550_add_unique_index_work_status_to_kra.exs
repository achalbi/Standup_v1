defmodule Standup.Repo.Migrations.AddUniqueIndexWorkStatusToKra do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    create unique_index(:key_result_areas, [:work_status_id], where: "work_status_id is not null", concurrently: true)
  end
end
