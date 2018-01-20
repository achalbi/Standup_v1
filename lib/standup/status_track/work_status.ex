defmodule Standup.StatusTrack.WorkStatus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.StatusTrack.{WorkStatus, Task}
  alias Standup.Accounts.User

  schema "work_statuses" do
    field :on_date, :date
    field :task_summary, :string
    field :user_name, :string
    field :user_email, :string
    field :sheet_row_id, :integer
    belongs_to :user, User
    has_many :tasks, Task

    timestamps()
  end

  @doc false
  def changeset(%WorkStatus{} = work_status, attrs) do
    work_status
    |> cast(attrs, [:user_name, :task_summary, :on_date, :user_id, :user_email, :sheet_row_id])
    |> validate_required([:user_id, :on_date, :user_email])
  end
end