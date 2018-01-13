defmodule Standup.StatusTrack.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.StatusTrack.Task

  alias Standup.StatusTrack.WorkStatus
  alias Standup.Accounts.User

  schema "tasks" do
    field :notes, :string
    field :on_date, :naive_datetime
    field :status, :string
    field :task_number, :string
    field :title, :string
    field :url, :string
    belongs_to :user, User
    belongs_to :work_status, WorkStatus

    timestamps()
  end

  @doc false
  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [:task_number, :title, :url, :status, :notes, :on_date, :user_id , :work_status_id])
    |> validate_required([:title, :status, :on_date, :notes])
  end
end
