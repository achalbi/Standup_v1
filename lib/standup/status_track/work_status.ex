defmodule Standup.StatusTrack.WorkStatus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.StatusTrack.{WorkStatus, Task}
  alias Standup.Accounts.User
  alias Standup.Organizations.Organization
  alias Standup.StatusTrack.WorkStatusType
  alias Standup.StatusTrack.KeyResultArea
  alias Standup.StatusTrack.Comment

  @working_at ["Working from Office": "WFO", "Working Remotely or Working From Home": "WFH", "Vacation or Paid-Time-Off": "PTO"]

  schema "work_statuses" do
    field :on_date, :date
    field :status_type, :string, default: "WFO"
    field :notes, :string
    field :task_summary, :string
    field :user_name, :string
    field :user_email, :string
    field :sheet_row_id, :integer
    belongs_to :user, User
    belongs_to :organization, Organization
    belongs_to :work_status_type, WorkStatusType
    has_many :tasks, Task
    has_many :comments, Comment
    has_one :key_result_area, KeyResultArea

    timestamps()
  end

  @doc false
  def changeset(%WorkStatus{} = work_status, attrs) do
    work_status
    |> cast(attrs, [:user_name, :task_summary, :on_date, :user_id, :user_email, :sheet_row_id, :status_type, :notes, :organization_id, :work_status_type_id])
    |> validate_required([:user_id, :on_date, :organization_id])
  end

  @doc false
  def working_at do
    @working_at
  end

  @doc false
  def working_at_map do
    @working_at
    |> Enum.into([], fn {key, val} -> {val,  Atom.to_string(key)} end)
    |> Enum.into(%{})
  end
end
