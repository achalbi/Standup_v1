defmodule StandupWeb.SpreadsheetControllerTest do
  use StandupWeb.ConnCase

  alias Standup.Spreadsheets

  @create_attrs %{spreadsheet_id: "some spreadsheet_id"}
  @update_attrs %{spreadsheet_id: "some updated spreadsheet_id"}
  @invalid_attrs %{spreadsheet_id: nil}

  def fixture(:spreadsheet) do
    {:ok, spreadsheet} = Spreadsheets.create_spreadsheet(@create_attrs)
    spreadsheet
  end

  describe "index" do
    test "lists all spreadsheets", %{conn: conn} do
      conn = get conn, spreadsheet_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Spreadsheets"
    end
  end

  describe "new spreadsheet" do
    test "renders form", %{conn: conn} do
      conn = get conn, spreadsheet_path(conn, :new)
      assert html_response(conn, 200) =~ "New Spreadsheet"
    end
  end

  describe "create spreadsheet" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, spreadsheet_path(conn, :create), spreadsheet: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == spreadsheet_path(conn, :show, id)

      conn = get conn, spreadsheet_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Spreadsheet"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, spreadsheet_path(conn, :create), spreadsheet: @invalid_attrs
      assert html_response(conn, 200) =~ "New Spreadsheet"
    end
  end

  describe "edit spreadsheet" do
    setup [:create_spreadsheet]

    test "renders form for editing chosen spreadsheet", %{conn: conn, spreadsheet: spreadsheet} do
      conn = get conn, spreadsheet_path(conn, :edit, spreadsheet)
      assert html_response(conn, 200) =~ "Edit Spreadsheet"
    end
  end

  describe "update spreadsheet" do
    setup [:create_spreadsheet]

    test "redirects when data is valid", %{conn: conn, spreadsheet: spreadsheet} do
      conn = put conn, spreadsheet_path(conn, :update, spreadsheet), spreadsheet: @update_attrs
      assert redirected_to(conn) == spreadsheet_path(conn, :show, spreadsheet)

      conn = get conn, spreadsheet_path(conn, :show, spreadsheet)
      assert html_response(conn, 200) =~ "some updated spreadsheet_id"
    end

    test "renders errors when data is invalid", %{conn: conn, spreadsheet: spreadsheet} do
      conn = put conn, spreadsheet_path(conn, :update, spreadsheet), spreadsheet: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Spreadsheet"
    end
  end

  describe "delete spreadsheet" do
    setup [:create_spreadsheet]

    test "deletes chosen spreadsheet", %{conn: conn, spreadsheet: spreadsheet} do
      conn = delete conn, spreadsheet_path(conn, :delete, spreadsheet)
      assert redirected_to(conn) == spreadsheet_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, spreadsheet_path(conn, :show, spreadsheet)
      end
    end
  end

  defp create_spreadsheet(_) do
    spreadsheet = fixture(:spreadsheet)
    {:ok, spreadsheet: spreadsheet}
  end
end
