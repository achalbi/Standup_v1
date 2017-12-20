defmodule Standup.Accounts.UserRole do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Accounts.{User, Role, UserRole}


  schema "user_roles" do
    belongs_to :user, User
    belongs_to :role, Role

    timestamps()
  end

  @doc false
  def changeset(%UserRole{} = user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id])
  end
end
