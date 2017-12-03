defmodule Standup.Repo.Migrations.AddProviderAndTokenToUser do
  use Ecto.Migration

  def change do
    alter table("credentials") do
      add :token, :string
    end
  end
end
