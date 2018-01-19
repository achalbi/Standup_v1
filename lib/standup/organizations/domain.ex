defmodule Standup.Organizations.Domain do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Organizations.{Domain, Organization}


  schema "domains" do
    field :name, :string
    belongs_to :organization, Organization

    timestamps()
  end

  @doc false
  def changeset(%Domain{} = domain, attrs) do
    domain
    |> cast(attrs, [:name, :organization_id])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
