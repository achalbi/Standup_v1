defmodule Standup.StatusTrack.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.StatusTrack.Task

  alias Standup.StatusTrack.WorkStatus
  alias Standup.Accounts.User
  alias Standup.Organizations.Team

  @tense_list ["Actual": "Actual", "Target": "Target"]


  schema "tasks" do
    field :notes, :string
    field :on_date, :naive_datetime
    field :status, :string
    field :task_number, :string
    field :title, :string
    field :url, :string
    field :tense, :string
    belongs_to :user, User
    belongs_to :team, Team
    belongs_to :work_status, WorkStatus
    field :work_status_type_id, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [:task_number, :title, :url, :status, :notes, :on_date, :user_id , :work_status_id, :team_id, :tense, :work_status_type_id])
    |> validate_required([:title, :status, :on_date, :team_id, :user_id])
  end
  
  @doc false
  def tense_list do
    @tense_list
  end
end
