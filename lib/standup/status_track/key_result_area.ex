defmodule Standup.StatusTrack.KeyResultArea do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.StatusTrack.KeyResultArea
  alias Standup.StatusTrack.WorkStatus


  schema "key_result_areas" do
    field :accountability, :string
    field :effective_communication, :boolean, default: false
    field :impediments, :string
    field :ownership, :string
    field :productivity, :float
    field :skill, :string
    belongs_to :work_status, WorkStatus

    timestamps()
  end

  @doc false
  def changeset(%KeyResultArea{} = key_result_area, attrs) do
    key_result_area
    |> cast(attrs, [:accountability, :ownership, :productivity, :skill, :effective_communication, :impediments, :work_status_id])
    |> validate_required([ :productivity,  :effective_communication])
  end
end
