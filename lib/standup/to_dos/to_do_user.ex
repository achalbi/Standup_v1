defmodule Standup.ToDos.ToDoUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.ToDos.ToDoUser


  schema "to_do_users" do
    field :to_do_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%ToDoUser{} = to_do_user, attrs) do
    to_do_user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
