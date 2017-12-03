defmodule Standup.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Accounts.{User, Credential}


  schema "users" do
    field :firstname, :string
    field :lastname, :string
    field :username, :string
    has_one :credential, Credential

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:firstname, :lastname, :username])
    |> validate_required([:firstname, :lastname])
  #  |> unique_constraint(:username)
  end
end
