defmodule Standup.Repo.Migrations.AddAvatarToCredential do
  use Ecto.Migration

  def change do
    alter table("credentials") do
      add :avatar, :string 
    end
  end
end
