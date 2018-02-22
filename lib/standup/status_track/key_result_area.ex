defmodule Standup.StatusTrack.KeyResultArea do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.StatusTrack.KeyResultArea


  schema "key_result_areas" do
    field :accountability, :string
    field :effective_communication, :boolean, default: false
    field :impediments, :string
    field :ownership, :string
    field :productivity, :float
    field :skill, :string
    field :work_status_id, :id

    timestamps()
  end

  @doc false
  def changeset(%KeyResultArea{} = key_result_area, attrs) do
    key_result_area
    |> cast(attrs, [:accountability, :ownership, :productivity, :skill, :effective_communication, :impediments])
    |> validate_required([:accountability, :ownership, :productivity, :skill, :effective_communication, :impediments])
  end
end
