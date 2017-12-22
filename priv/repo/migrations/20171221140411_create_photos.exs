defmodule Standup.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :public_id, :string
      add :secure_url, :text

      timestamps()
    end

  end
end
