defmodule Standup.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Accounts.{User, Credential, Role, UserRole}
  alias Standup.Organizations.{Team, UserTeam, Organization, UserOrganization}
  alias Standup.Galleries.Photo
  alias Standup.StatusTrack.WorkStatus

  schema "users" do
    field :firstname, :string
    field :lastname, :string
    field :username, :string
    field :avatar, :string
    belongs_to :photo, Photo, on_replace: :nilify 
    has_one :credential, Credential
    many_to_many :roles, Role, join_through: UserRole
    many_to_many :organizations, Organization, join_through: UserOrganization  
    many_to_many :teams, Team, join_through: UserTeam 
    has_many :work_statuses, WorkStatus

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:firstname, :lastname, :username, :avatar])
    |> validate_required([])
  #  |> unique_constraint(:username)
  end
end
