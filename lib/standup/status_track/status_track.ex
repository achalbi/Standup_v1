defmodule Standup.StatusTrack do
  @moduledoc """
  The StatusTrack context.
  """
  use Timex

  require IEx

  import Ecto.Query, warn: false
  alias Standup.Repo
  alias Standup.Accounts.User
  alias Standup.Accounts
  alias Standup.Organizations

  alias Standup.StatusTrack.WorkStatus
  alias Standup.StatusTrack.WorkStatusType
  alias Standup.StatusTrack.KeyResultArea
  alias Standup.StatusTrack.Task
  @doc """
  Returns the list of work_statuses.

  ## Examples

      iex> list_work_statuses()
      [%WorkStatus{}, ...]

  """
	def list_work_statuses(conn) do
		current_user = Guardian.Plug.current_resource(conn)

		work_status = from w in WorkStatus,
		where: w.user_id == ^current_user.id,
		preload: [:tasks],
        order_by: [desc: w.on_date]
		
        Repo.all(work_status)
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
  def get_work_status!(id), do: Repo.get!(WorkStatus, id) |> Repo.preload([:work_status_type, :key_result_area, :comments, tasks: [:team]])

  @doc """
  Creates a work_status.

  ## Examples

      iex> create_work_status(%{field: value})
      {:ok, %WorkStatus{}}

      iex> create_work_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work_status(attrs \\ %{}) do
    attrs = case attrs do
        %{"notes" => notes, "status_type" => status_type, "user_id" => user_id} ->
            user = User
            |> Repo.get!(user_id)
            |> Repo.preload(:credential)

            user_name  = user.firstname <> " " <> user.lastname
            task_summary = Map.get(Standup.StatusTrack.WorkStatus.working_at_map, status_type) <> "\n" <> notes <> "\n"
            Map.merge(attrs, %{"task_summary" => task_summary, "user_id" => user_id, "user_name" => user_name, "user_email" => user.credential.email })
        _ -> attrs
        end
		
   	work_status_result = %WorkStatus{}
    |> WorkStatus.changeset(attrs)
    |> Repo.insert()

    case work_status_result do
       {:ok, work_status} ->
            sync_with_spreadsheet(work_status)
            work_status_result
        _ -> work_status_result
    end
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
    work_status_result = work_status
    |> WorkStatus.changeset(attrs)
    |> Repo.update()

    case work_status_result do
       {:ok, work_status} ->
            sync_with_spreadsheet(work_status)
            work_status_result
        _ -> work_status_result
    end
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


  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
	def list_tasks(conn) do
		current_user = Guardian.Plug.current_resource(conn)
		tasks = from t in Task,
		where: t.user_id == ^current_user.id,
		preload: [:work_status],
    order_by: [desc: t.on_date]
		
    Repo.all(tasks)
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
  def get_task!(id), do: Repo.get!(Task, id) |> Repo.preload([:work_status, :team])
	
	def get_task_by_work_status_and_tense(id, tense) do
		query = from t in Task,
			where: t.tense == ^tense and t.work_status_id == ^id,
			distinct: true,
			order_by: [desc: t.updated_at],
			preload: [:work_status, :team],
			select: t

		 Repo.all(query)
    end
    
    def get_task_by_work_status_and_next_target(id) do
        ws = get_work_status!(id)
        {:ok, datetime} = NaiveDateTime.new(ws.on_date, ~T[00:00:00])
        query = from w in WorkStatus,
				where: w.on_date > ^datetime,
				preload: [:tasks],
        order_by: [asc: w.on_date],
        limit: 1
        work_status = Repo.one(query)
        if work_status do
          	query = from t in Task,
            where: t.tense == "Target" and t.work_status_id == ^work_status.id,
            distinct: true,
            order_by: [desc: t.updated_at],
            preload: [:work_status, :team],
            select: t
            
            Repo.all(query)
        else
            []
        end

	end
  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
	def create_task(attrs \\ %{}) do
    %Task{}
			|> Task.changeset(attrs)
			|> Repo.insert()
	end
    
	defp task_summary(task) do
    task = task |> Repo.preload(:team)
    task_number = if task.task_number, do: task.task_number <> ": ", else: ""
    task_notes = if task.notes, do: task.notes, else: ""
    task_number <> task.title <> "\n" <> "Team: " <> task.team.name <>"\n" <> "status: " <> task.status <> "\n" <> "Actual/Target: " <> task.tense <> "\n" <> task_notes 
	end

	def prepare_work_status_from_task(%Task{} = task, attrs \\ %{}) do
		#current_user = Guardian.Plug.current_resource(conn)
		user = User
        |> Repo.get!(task.user_id)
        |> Repo.preload(:credential)
            
        [domain] = Accounts.get_domain_by_user_email(user)
        organization = Organizations.get_organization_from_domain!(domain)

		user_name  = user.firstname <> " " <> user.lastname
        task_summary = task_summary(task)

		work_status_attrs = %{"on_date" => task.on_date, "task_summary" => task_summary, "user_id" => task.user_id, "user_name" => user_name, "user_email" => user.credential.email, "organization_id" => organization.id, "work_status_type_id" => attrs["work_status_type_id"] }
		case create_or_update_work_status(task.on_date, task.user_id, work_status_attrs) do
    	{:ok, work_status} ->
				task
				|> Repo.preload(:work_status) 
				|> Task.changeset(attrs)
				|> Ecto.Changeset.put_assoc(:work_status, work_status)
				|> Repo.update()
			{:error, changeset} -> {:error, changeset}
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
				task_summary = task_summary(task)
				attrs = Map.put(attrs, "task_summary", task_summary)

				case update_work_status_from_tasks(work_status, task.on_date, task.user_id, attrs) do
						{:ok, _work_status} ->
								# sync_with_spreadsheet(work_status)
								{:ok, task}
						{:error, _reason} -> {:error, "could not update Work Status"}
				end
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
		work_status_id = task.work_status.id
		delete_task_result = Repo.delete(task)
		work_status = get_work_status!(work_status_id)

		case update_work_status_from_tasks(work_status, task.on_date, task.user_id) do
			{:ok, _work_status} ->
					#sync_with_spreadsheet(work_status)
					{:ok, task}
			{:error, _reason} -> {:error, "could not update Work Status"}
    end
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
                update_work_status_from_tasks(work_status, date, user_id, attrs)
				# case update_work_status_from_tasks(work_status, date, user_id, attrs) do
				# 	{:ok, work_status} ->
				# 		sync_with_spreadsheet(work_status)
				# 		{:ok, work_status}
				# end
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
			select: t
		 Repo.all(query)
	end

	def update_work_status_from_tasks(%WorkStatus{} = work_status, date, user_id, attrs \\ %{}) do
		task_summary = case get_tasks_by_date_and_user_id(date, user_id) do
				[] -> attrs["task_summary"] || " "
				tasks ->
					#formatted_tasks = Enum.map(tasks, fn(x) -> Enum.at(x, 0) <> ": " <> Enum.at(x, 1) <> "\n" <> "status: " <> Enum.at(x, 2) <> "\n" <> Enum.at(x, 3) end)
					formatted_tasks = Enum.map(tasks, fn(task) -> task_summary(task) end)
					Enum.map_join(formatted_tasks, "\n\n", &(&1))
            end
            IEx.pry
        work_status_details = Map.get(Standup.StatusTrack.WorkStatus.working_at_map, work_status.status_type) <> "\n" <> (work_status.notes || "") <> "\n\n"
		attrs = Map.put(attrs, "task_summary", work_status_details <> task_summary)	
		attrs = Map.put(attrs, "notes", work_status.notes)	
		update_work_status(work_status, attrs)
    end
    
	def update_work_status_with_tasks(%WorkStatus{} = work_status, attrs \\ %{}) do
			#todo:
			#tasks = Enum.map(work_status.tasks, fn(t) -> [t.task_number, t.title, t.status, t.notes] end)
			#formatted_tasks = Enum.map(tasks, fn(x) -> Enum.at(x, 0) <> ": " <> Enum.at(x, 1) <> "\n" <> "status: " <> Enum.at(x, 2) <> "\n" <> Enum.at(x, 3) end)
			formatted_tasks = Enum.map(work_status.tasks, fn(task) -> task_summary(task) end)
			task_summary = Enum.map_join(formatted_tasks, "\n\n", &(&1))
            work_status_details = Map.get(Standup.StatusTrack.WorkStatus.working_at_map, attrs["status_type"]) <> "\n" <>  attrs["notes"] <> "\n\n"
			attrs = Map.put(attrs, "task_summary", work_status_details <> task_summary)	
		#	attrs = Map.put(attrs, "notes", work_status.notes)	
			update_work_status(work_status, attrs)
    end
    
	def sync_with_spreadsheet(%WorkStatus{} = work_status) do
		#spreadsheet_id = System.get_env("SPREADSHEET_ID")
		spreadsheet = Standup.Spreadsheets.list_spreadsheets(work_status.organization_id)
		if (spreadsheet && spreadsheet.status == "Active") do
			try do
				case GSS.Spreadsheet.Supervisor.spreadsheet(spreadsheet.spreadsheet_id) do
					{:ok, pid} ->
						case GSS.Spreadsheet.rows(pid) do
							{:ok, row_count} ->
								if row_count == 0, do: GSS.Spreadsheet.write_row(pid, 1, ["Name", "Date", "Task Summary"])
								
								row_no = work_status.sheet_row_id
								update_spreadsheet(work_status, pid, row_no)
							{:error, reason} -> reason
						end
					{:error, reason} -> reason
				end
			rescue
				_error -> {:error}
			catch
				_error -> {:error}
			end
		end
	end

	def sync_with_spreadsheet_and_handle_error(%WorkStatus{} = work_status) do
		case sync_with_spreadsheet(work_status) do
			{:error} -> sync_with_spreadsheet_and_handle_error(work_status)
			response -> response
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

	def work_status_last_updated_on(conn) do
		current_user = Guardian.Plug.current_resource(conn)
		tasks = from t in WorkStatus,
		where: t.user_id == ^current_user.id,
		order_by: [desc: t.on_date],
		limit: 1
    Repo.one(tasks)
	end

	def list_work_statuses_by_team_and_date(team, date) do
		query = from t in Task,
			join: ws in WorkStatus,
			where: t.on_date == ^date and t.team_id == ^team.id and t.work_status_id == ws.id,
			distinct: true,
   		order_by: [desc: ws.updated_at],
			select: ws

		 work_statuses = Repo.all(query)
		 work_statuses |> Repo.preload([user: :photo])
	end

  @doc """
  Returns the list of work_status_types.

  ## Examples

      iex> list_work_status_types()
      [%WorkStatusType{}, ...]

  """
  def list_work_status_types(org_id) do
    from(w in WorkStatusType, where: w.organization_id == ^org_id)
    |> Repo.all()
  end

  @doc """
  Gets a single work_status_type.

  Raises `Ecto.NoResultsError` if the Work status type does not exist.

  ## Examples

      iex> get_work_status_type!(123)
      %WorkStatusType{}

      iex> get_work_status_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_work_status_type!(id), do: Repo.get!(WorkStatusType, id) |> Repo.preload([:organization])

  @doc """
  Creates a work_status_type.

  ## Examples

      iex> create_work_status_type(%{field: value})
      {:ok, %WorkStatusType{}}

      iex> create_work_status_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work_status_type(attrs \\ %{}) do
    result = %WorkStatusType{}
    |> WorkStatusType.changeset(attrs)
    |> Repo.insert()
    case result do
        {:ok, work_status_type } -> 
            work_status_type =  work_status_type |> Repo.preload([:organization])
            {:ok, work_status_type }
        result -> result
    end
  end

  @doc """
  Updates a work_status_type.

  ## Examples

      iex> update_work_status_type(work_status_type, %{field: new_value})
      {:ok, %WorkStatusType{}}

      iex> update_work_status_type(work_status_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_status_type(%WorkStatusType{} = work_status_type, attrs) do
    work_status_type
    |> WorkStatusType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a WorkStatusType.

  ## Examples

      iex> delete_work_status_type(work_status_type)
      {:ok, %WorkStatusType{}}

      iex> delete_work_status_type(work_status_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_work_status_type(%WorkStatusType{} = work_status_type) do
    Repo.delete(work_status_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work_status_type changes.

  ## Examples

      iex> change_work_status_type(work_status_type)
      %Ecto.Changeset{source: %WorkStatusType{}}

  """
  def change_work_status_type(%WorkStatusType{} = work_status_type) do
    WorkStatusType.changeset(work_status_type, %{})
  end

  @doc """
  Returns the list of key_result_areas.

  ## Examples

      iex> list_key_result_areas()
      [%KeyResultArea{}, ...]

  """
  def list_key_result_areas do
    Repo.all(KeyResultArea)
  end

  @doc """
  Gets a single key_result_area.

  Raises `Ecto.NoResultsError` if the Key result area does not exist.

  ## Examples

      iex> get_key_result_area!(123)
      %KeyResultArea{}

      iex> get_key_result_area!(456)
      ** (Ecto.NoResultsError)

  """
  def get_key_result_area!(id), do: Repo.get!(KeyResultArea, id) |> Repo.preload([:work_status])

  @doc """
  Creates a key_result_area.

  ## Examples

      iex> create_key_result_area(%{field: value})
      {:ok, %KeyResultArea{}}

      iex> create_key_result_area(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_key_result_area(attrs \\ %{}) do
    %KeyResultArea{}
    |> KeyResultArea.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a key_result_area.

  ## Examples

      iex> update_key_result_area(key_result_area, %{field: new_value})
      {:ok, %KeyResultArea{}}

      iex> update_key_result_area(key_result_area, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_key_result_area(%KeyResultArea{} = key_result_area, attrs) do
    key_result_area
    |> KeyResultArea.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a KeyResultArea.

  ## Examples

      iex> delete_key_result_area(key_result_area)
      {:ok, %KeyResultArea{}}

      iex> delete_key_result_area(key_result_area)
      {:error, %Ecto.Changeset{}}

  """
  def delete_key_result_area(%KeyResultArea{} = key_result_area) do
    Repo.delete(key_result_area)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking key_result_area changes.

  ## Examples

      iex> change_key_result_area(key_result_area)
      %Ecto.Changeset{source: %KeyResultArea{}}

  """
  def change_key_result_area(%KeyResultArea{work_status_id: work_status_id} = key_result_area) do
    summary = accountability_summary(work_status_id)
    attrs = %{work_status_id: work_status_id, accountability: summary, productivity: 100}
    KeyResultArea.changeset(key_result_area, attrs)
  end

  def accountability_summary(work_status_id) do
    actual_tasks = get_task_by_work_status_and_tense(work_status_id, "Actual")
    target_tasks = get_task_by_work_status_and_tense(work_status_id, "Target")
    summary = if Enum.count(target_tasks) > 0, do: "Target:\n", else: "" 
    summary = Enum.reduce(target_tasks, summary, fn(task, summary) -> summary <> (if task.task_number, do: task.task_number <>  ": ", else: "" ) <> task.title <> "\n" end)
    summary = summary <> if Enum.count(actual_tasks) > 0, do: "\nActual:\n", else: ""
    Enum.reduce(actual_tasks, summary, fn(task, summary) -> summary <> (if task.task_number, do: task.task_number <>  ": ", else: "" ) <> task.title <> "\n" end)
	end


	def update_key_result_area_accountability(work_status_id) do
		work_status = get_work_status!(work_status_id)
		if work_status.key_result_area do
			summary = accountability_summary(work_status_id)
			KeyResultArea.changeset(work_status.key_result_area, %{"accountability" => summary})
			|> Repo.update()
		end
	end

  alias Standup.StatusTrack.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments(work_status_id) do
    from(c in Comment, where: c.work_status_id == ^work_status_id, order_by: [desc: c.inserted_at])
    |> Repo.all()
    |> Repo.preload([:work_status, user: [:credential, :photo]])
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id) |> Repo.preload([:work_status, user: [:credential, :photo]])

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{source: %Comment{}}

  """
  def change_comment(%Comment{} = comment) do
    Comment.changeset(comment, %{})
  end
end
