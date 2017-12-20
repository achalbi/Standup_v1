defmodule Standup.Repo.Migrations.CreateIndexForOrg do
  use Ecto.Migration

  def change do
    create index("organizations", [:name])
  end
end
