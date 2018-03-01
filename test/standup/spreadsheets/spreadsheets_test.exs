defmodule Standup.SpreadsheetsTest do
  use Standup.DataCase

  alias Standup.Spreadsheets

  describe "spreadsheets" do
    alias Standup.Spreadsheets.Spreadsheet

    @valid_attrs %{spreadsheet_id: "some spreadsheet_id"}
    @update_attrs %{spreadsheet_id: "some updated spreadsheet_id"}
    @invalid_attrs %{spreadsheet_id: nil}

    def spreadsheet_fixture(attrs \\ %{}) do
      {:ok, spreadsheet} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Spreadsheets.create_spreadsheet()

      spreadsheet
    end

    test "list_spreadsheets/0 returns all spreadsheets" do
      spreadsheet = spreadsheet_fixture()
      assert Spreadsheets.list_spreadsheets() == [spreadsheet]
    end

    test "get_spreadsheet!/1 returns the spreadsheet with given id" do
      spreadsheet = spreadsheet_fixture()
      assert Spreadsheets.get_spreadsheet!(spreadsheet.id) == spreadsheet
    end

    test "create_spreadsheet/1 with valid data creates a spreadsheet" do
      assert {:ok, %Spreadsheet{} = spreadsheet} = Spreadsheets.create_spreadsheet(@valid_attrs)
      assert spreadsheet.spreadsheet_id == "some spreadsheet_id"
    end

    test "create_spreadsheet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spreadsheets.create_spreadsheet(@invalid_attrs)
    end

    test "update_spreadsheet/2 with valid data updates the spreadsheet" do
      spreadsheet = spreadsheet_fixture()
      assert {:ok, spreadsheet} = Spreadsheets.update_spreadsheet(spreadsheet, @update_attrs)
      assert %Spreadsheet{} = spreadsheet
      assert spreadsheet.spreadsheet_id == "some updated spreadsheet_id"
    end

    test "update_spreadsheet/2 with invalid data returns error changeset" do
      spreadsheet = spreadsheet_fixture()
      assert {:error, %Ecto.Changeset{}} = Spreadsheets.update_spreadsheet(spreadsheet, @invalid_attrs)
      assert spreadsheet == Spreadsheets.get_spreadsheet!(spreadsheet.id)
    end

    test "delete_spreadsheet/1 deletes the spreadsheet" do
      spreadsheet = spreadsheet_fixture()
      assert {:ok, %Spreadsheet{}} = Spreadsheets.delete_spreadsheet(spreadsheet)
      assert_raise Ecto.NoResultsError, fn -> Spreadsheets.get_spreadsheet!(spreadsheet.id) end
    end

    test "change_spreadsheet/1 returns a spreadsheet changeset" do
      spreadsheet = spreadsheet_fixture()
      assert %Ecto.Changeset{} = Spreadsheets.change_spreadsheet(spreadsheet)
    end
  end
end
