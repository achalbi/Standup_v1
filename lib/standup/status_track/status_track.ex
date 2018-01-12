defmodule Standup.StatusTrack do
  @moduledoc """
  The StatusTrack context.
  """
  use Timex

  require IEx

  import Ecto.Query, warn: false
  alias Standup.Repo
  alias Standup.Accounts.User

  alias Standup.StatusTrack.WorkStatus

  @doc """
  Returns the list of work_statuses.

  ## Examples

      iex> list_work_statuses()
      [%WorkStatus{}, ...]

  """
  def list_work_statuses do
    Repo.all(WorkStatus)
  end

  @doc """
  Gets a single work_status.

  Raises `Ecto.NoResultsError` if the Work status does not exist.

  ## Examples

      iex> get_work_status!(123)
      %WorkStatus{}

      iex> get_work_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_work_status!(id), do: Repo.get!(WorkStatus, id)

  @doc """
  Creates a work_status.

  ## Examples

      iex> create_work_status(%{field: value})
      {:ok, %WorkStatus{}}

      iex> create_work_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work_status(attrs \\ %{}) do
    %WorkStatus{}
    |> WorkStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a work_status.

  ## Examples

      iex> update_work_status(work_status, %{field: new_value})
      {:ok, %WorkStatus{}}

      iex> update_work_status(work_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_status(%WorkStatus{} = work_status, attrs) do
    work_status
    |> WorkStatus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a WorkStatus.

  ## Examples

      iex> delete_work_status(work_status)
      {:ok, %WorkStatus{}}

      iex> delete_work_status(work_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_work_status(%WorkStatus{} = work_status) do
    Repo.delete(work_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work_status changes.

  ## Examples

      iex> change_work_status(work_status)
      %Ecto.Changeset{source: %WorkStatus{}}

  """
  def change_work_status(%WorkStatus{} = work_status) do
    WorkStatus.changeset(work_status, %{})
  end

  alias Standup.StatusTrack.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id) |> Repo.preload(:work_status)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    date = Timex.parse!(attrs["on_date"], "%Y-%m-%d", :strftime)
    attrs = Map.put(attrs, "on_date", date)
    {:ok, task} = %Task{}
        |> Task.changeset(attrs)
		|> Repo.insert()

		#current_user = Guardian.Plug.current_resource(conn)
		user = User
        |> Repo.get!(task.user_id)
        |> Repo.preload(:credential)

		user_name  = user.firstname <> " " <> user.lastname
		task_summary = task.task_number <> ": " <> task.title <> "\n" <> "status: " <> task.status <> "\n" <> task.notes 

		work_status_attrs = %{"on_date" => date, "task_summary" => task_summary, "user_id" => task.user_id, "user_name" => user_name, "user_email" => user.credential.email }
		case create_or_update_work_status(date, task.user_id, work_status_attrs) do
    	{:ok, work_status} ->
				task
				|> Repo.preload(:work_status) 
				|> Task.changeset(attrs)
				|> Ecto.Changeset.put_assoc(:work_status, work_status)
				|> Repo.update()
			{:error, _} -> task
		end
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
	def update_task(%Task{} = task, %WorkStatus{} = work_status, attrs) do
		date = Timex.parse!(attrs["on_date"], "%Y-%m-%d", :strftime)
		attrs = Map.put(attrs, "on_date", date)
		
		update_task_result = task
		|> Repo.preload(:work_status) 
		|> Task.changeset(attrs)
		|> Ecto.Changeset.put_assoc(:work_status, work_status)
		|> Repo.update()

		case update_task_result do
			{:ok, task} -> 
                task_summary = task.task_number <> ": " <> task.title <> "\n" <> "status: " <> task.status <> "\n" <> task.notes 
                attrs = Map.put(attrs, "task_summary", task_summary)

                update_work_status_from_tasks(work_status, task.on_date, task.user_id, attrs)
                update_task_result

			{:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
		end 

  end

  @doc """
  Deletes a Task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
		delete_task_result = Repo.delete(task)
		
		update_work_status_from_tasks(task.work_status, task.on_date, task.user_id)
		delete_task_result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{source: %Task{}}

  """
	def change_task(conn, %Task{} = task) do
		current_user = Guardian.Plug.current_resource(conn)
    Task.changeset(task, %{"user_id" => current_user.id})
  end

	def create_or_update_work_status(date, user_id, attrs \\ %{}) do
		case get_work_status_by_date_and_user_id(date, user_id) do
			%WorkStatus{} = work_status ->
				case update_work_status_from_tasks(work_status, date, user_id, attrs) do
					{:ok, work_status} ->
						sync_with_spreadsheet(work_status)
						{:ok, work_status}
				end
			nil ->
				case create_work_status(attrs) do
					{:ok, work_status} ->
						sync_with_spreadsheet(work_status)
						{:ok, work_status}
				end
		end
	end

	def get_work_status_by_date_and_user_id(date, user_id), do: Repo.get_by(WorkStatus, on_date: date, user_id: user_id )
	
	def get_tasks_by_date_and_user_id(date, user_id) do
		query = from t in Task,
			where: t.on_date == ^date and t.user_id == ^user_id,
			select: [t.task_number, t.title, t.status, t.notes]
		 Repo.all(query)
	end

	def update_work_status_from_tasks(%WorkStatus{} = work_status, date, user_id, attrs \\ %{}) do
		task_summary = case get_tasks_by_date_and_user_id(date, user_id) do
				[] -> attrs["task_summary"]
				tasks ->
					formatted_tasks = Enum.map(tasks, fn(x) -> Enum.at(x, 0) <> ": " <> Enum.at(x, 1) <> "\n" <> "status: " <> Enum.at(x, 2) <> "\n" <> Enum.at(x, 3) end)
					Enum.map_join(formatted_tasks, "\n\n", &(&1))
			end

		attrs = Map.put(attrs, "task_summary", task_summary)	
		update_work_status(work_status, attrs)
	end
    
	def sync_with_spreadsheet(%WorkStatus{} = work_status) do
		case GSS.Spreadsheet.Supervisor.spreadsheet(System.get_env("SPREADSHEET_ID")) do
			{:ok, pid} ->
				{:ok, row_count} = GSS.Spreadsheet.rows(pid)
					if row_count == 0, do: GSS.Spreadsheet.write_row(pid, 1, ["Name", "Date", "Task Summary"])
				 
				row_no = work_status.sheet_row_id
				update_spreadsheet(work_status, pid, row_no)
			{:error, reason} -> reason
		end
	end

	def update_spreadsheet(%WorkStatus{} = work_status, pid, row_no) when row_no == nil do
		on_date = Timex.format!(work_status.on_date, "%m-%d-%Y", :strftime)
		GSS.Spreadsheet.append_row(pid, 1, [work_status.user_name, on_date, work_status.task_summary])
		case GSS.Spreadsheet.rows(pid) do
			{:ok, row_id} -> 
						update_work_status(work_status, %{sheet_row_id: row_id} )
			{:error, reason} -> reason
		end
	end

	def update_spreadsheet(%WorkStatus{} = work_status, pid, row_no) do
		on_date = Timex.format!(work_status.on_date, "%m-%d-%Y", :strftime)
		GSS.Spreadsheet.write_row(pid, row_no, [work_status.user_name, on_date, work_status.task_summary])
	end
end
