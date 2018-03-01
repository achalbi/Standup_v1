defmodule Standup.Spreadsheets do
  @moduledoc """
  The Spreadsheets context.
  """

  import Ecto.Query, warn: false
  alias Standup.Repo

  alias Standup.Spreadsheets.Spreadsheet
  alias Standup.Organizations.Organization

  @doc """
  Returns the list of spreadsheets.

  ## Examples

      iex> list_spreadsheets()
      [%Spreadsheet{}, ...]

  """
  def list_spreadsheets(organization_id) do
    organization = Repo.get!(Organization, organization_id) |> Repo.preload([:spreadsheet])
    organization.spreadsheet
  end

  @doc """
  Gets a single spreadsheet.

  Raises `Ecto.NoResultsError` if the Spreadsheet does not exist.

  ## Examples

      iex> get_spreadsheet!(123)
      %Spreadsheet{}

      iex> get_spreadsheet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_spreadsheet!(id), do: Repo.get!(Spreadsheet, id) |> Repo.preload([:organization])

  @doc """
  Creates a spreadsheet.

  ## Examples

      iex> create_spreadsheet(%{field: value})
      {:ok, %Spreadsheet{}}

      iex> create_spreadsheet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_spreadsheet(attrs \\ %{}) do
    %Spreadsheet{}
    |> Spreadsheet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a spreadsheet.

  ## Examples

      iex> update_spreadsheet(spreadsheet, %{field: new_value})
      {:ok, %Spreadsheet{}}

      iex> update_spreadsheet(spreadsheet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_spreadsheet(%Spreadsheet{} = spreadsheet, attrs) do
    spreadsheet
    |> Spreadsheet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Spreadsheet.

  ## Examples

      iex> delete_spreadsheet(spreadsheet)
      {:ok, %Spreadsheet{}}

      iex> delete_spreadsheet(spreadsheet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_spreadsheet(%Spreadsheet{} = spreadsheet) do
    Repo.delete(spreadsheet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking spreadsheet changes.

  ## Examples

      iex> change_spreadsheet(spreadsheet)
      %Ecto.Changeset{source: %Spreadsheet{}}

  """
  def change_spreadsheet(%Spreadsheet{} = spreadsheet) do
    Spreadsheet.changeset(spreadsheet, %{})
  end
end
