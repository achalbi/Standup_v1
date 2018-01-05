defmodule Standup.StatusTrack.WorkStatus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.StatusTrack.WorkStatus
  alias Standup.Accounts.User

  schema "work_statuses" do
    field :on_date, :date
    field :task_summary, :string
    field :user_name, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%WorkStatus{} = work_status, attrs) do
    work_status
    |> cast(attrs, [:user_name, :task_summary, :on_date, :user_id])
    |> validate_required([:user_id, :on_date])
  end
end
