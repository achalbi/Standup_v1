defmodule Standup.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Accounts.{Role, User, UserRole}


  schema "roles" do
    field :description, :string
    field :key, :string
    field :name, :string
    many_to_many :users, User, join_through: UserRole

    timestamps()
  end

  @doc false
  def changeset(%Role{} = role, attrs) do
    role
    |> cast(attrs, [:key, :name, :description])
    |> validate_required([:key, :name])
  end
end
