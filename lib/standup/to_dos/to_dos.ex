defmodule Standup.ToDos do
  @moduledoc """
  The ToDos context.
  """

  import Ecto.Query, warn: false
  alias Standup.Repo

  alias Standup.ToDos.ToDo
  alias Standup.Organizations
  alias Standup.Accounts.User

  @doc """
  Returns the list of to_dos.

  ## Examples

      iex> list_to_dos()
      [%ToDo{}, ...]

  """
  def list_to_dos(organization_id, day, privacy, status, user_id) do
    query =
      from(
        t in ToDo,
        where: t.organization_id == ^organization_id,
        where: t.user_id == ^user_id
      )

    if day == Standup.ToDos.ToDo.day()[:Today] do
      {:ok, datetime} = NaiveDateTime.new(Date.utc_today(), ~T[00:00:00])
      query = from(t in query, where: t.start_date == ^datetime)
    end

    if privacy && privacy != "" do
      query = from(t in query, where: t.list_type == ^privacy)
    end

    if status && status != "" do
      query = from(t in query, where: t.status == ^status)
    end

    query = from(t in query, order_by: [desc: t.start_date], preload: [:organization])

    Repo.all(query)
  end

  @doc """
  Returns the list of to_dos by date.

  ## Examples

      iex> list_to_dos_by_date()
      [%ToDo{}, ...]

  """
  def list_to_dos_by_date(organization_id, date, privacy, status, user_id) do
    query =
      from(
        t in ToDo,
        where: t.organization_id == ^organization_id,
        where: t.user_id == ^user_id
      )

    query = from(t in query, where: t.start_date <= ^date, where: t.end_date >= ^date)

    if privacy && privacy != "" do
      query = from(t in query, where: t.list_type == ^privacy)
    end

    if status && status != "" do
      query = from(t in query, where: t.status == ^status)
    end

    query = from(t in query, order_by: [desc: t.end_date], preload: [:organization])

    Repo.all(query)
  end

  def list_to_dos_by_team_and_date(team, date) do
    users = Organizations.get_team_users(team.id)
    team_users = Enum.map(users, fn user -> user.id end)
    privacy = Standup.ToDos.ToDo.privacy()[:Public]

    query =
      from(
        t in ToDo,
        join: u in User,
        where: t.start_date <= ^date and t.end_date >= ^date,
        where: t.user_id in ^team_users,
        where: t.user_id == u.id,
        where: t.list_type == ^privacy,
        order_by: [asc: u.firstname],
        order_by: [desc: t.start_date],
        select: t
      )

    to_dos = Repo.all(query)
    to_dos |> Repo.preload(user: :photo)
  end

  @doc """
  Gets a single to_do.

  Raises `Ecto.NoResultsError` if the To do does not exist.

  ## Examples

      iex> get_to_do!(123)
      %ToDo{}

      iex> get_to_do!(456)
      ** (Ecto.NoResultsError)

  """
  def get_to_do!(id), do: Repo.get!(ToDo, id) |> Repo.preload([:organization])

  @doc """
  Creates a to_do.

  ## Examples

      iex> create_to_do(%{field: value})
      {:ok, %ToDo{}}

      iex> create_to_do(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_to_do(attrs \\ %{}) do
    %ToDo{}
    |> ToDo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a to_do.

  ## Examples

      iex> update_to_do(to_do, %{field: new_value})
      {:ok, %ToDo{}}

      iex> update_to_do(to_do, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_to_do(%ToDo{} = to_do, attrs) do
    to_do
    |> ToDo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ToDo.

  ## Examples

      iex> delete_to_do(to_do)
      {:ok, %ToDo{}}

      iex> delete_to_do(to_do)
      {:error, %Ecto.Changeset{}}

  """
  def delete_to_do(%ToDo{} = to_do) do
    Repo.delete(to_do)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking to_do changes.

  ## Examples

      iex> change_to_do(to_do)
      %Ecto.Changeset{source: %ToDo{}}

  """
  def change_to_do(%ToDo{} = to_do) do
    ToDo.changeset(to_do, %{})
  end

  alias Standup.ToDos.ToDoUser

  @doc """
  Returns the list of to_do_users.

  ## Examples

      iex> list_to_do_users()
      [%ToDoUser{}, ...]

  """
  def list_to_do_users do
    Repo.all(ToDoUser)
  end

  @doc """
  Gets a single to_do_user.

  Raises `Ecto.NoResultsError` if the To do user does not exist.

  ## Examples

      iex> get_to_do_user!(123)
      %ToDoUser{}

      iex> get_to_do_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_to_do_user!(id), do: Repo.get!(ToDoUser, id)

  @doc """
  Creates a to_do_user.

  ## Examples

      iex> create_to_do_user(%{field: value})
      {:ok, %ToDoUser{}}

      iex> create_to_do_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_to_do_user(attrs \\ %{}) do
    %ToDoUser{}
    |> ToDoUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a to_do_user.

  ## Examples

      iex> update_to_do_user(to_do_user, %{field: new_value})
      {:ok, %ToDoUser{}}

      iex> update_to_do_user(to_do_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_to_do_user(%ToDoUser{} = to_do_user, attrs) do
    to_do_user
    |> ToDoUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ToDoUser.

  ## Examples

      iex> delete_to_do_user(to_do_user)
      {:ok, %ToDoUser{}}

      iex> delete_to_do_user(to_do_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_to_do_user(%ToDoUser{} = to_do_user) do
    Repo.delete(to_do_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking to_do_user changes.

  ## Examples

      iex> change_to_do_user(to_do_user)
      %Ecto.Changeset{source: %ToDoUser{}}

  """
  def change_to_do_user(%ToDoUser{} = to_do_user) do
    ToDoUser.changeset(to_do_user, %{})
  end
end
