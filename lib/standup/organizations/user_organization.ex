defmodule Standup.Organizations.UserOrganization do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Organizations.{UserOrganization, Organization}
  alias Standup.Accounts.User


  schema "user_organizations" do
    field :is_moderator, :boolean, default: false
    belongs_to :user, User
    belongs_to :organization, Organization

    timestamps()
  end

  @doc false
  def changeset(%UserOrganization{} = user_organization, attrs) do
    user_organization
    |> cast(attrs, [:is_moderator])
    |> validate_required([:is_moderator])
  end
end
