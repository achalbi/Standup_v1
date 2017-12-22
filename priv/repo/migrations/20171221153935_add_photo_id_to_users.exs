defmodule Standup.Repo.Migrations.AddPhotoIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :photo_id, references(:photos, on_delete: :delete_all)
    end
  end
end
