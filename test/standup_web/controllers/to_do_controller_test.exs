defmodule StandupWeb.ToDoControllerTest do
  use StandupWeb.ConnCase

  alias Standup.ToDos

  @create_attrs %{description: "some description", end_date: "2010-04-17 14:00:00.000000Z", item_number: "some item_number", list_type: "some list_type", ownership: "some ownership", start_date: "2010-04-17 14:00:00.000000Z", status: "some status", title: "some title"}
  @update_attrs %{description: "some updated description", end_date: "2011-05-18 15:01:01.000000Z", item_number: "some updated item_number", list_type: "some updated list_type", ownership: "some updated ownership", start_date: "2011-05-18 15:01:01.000000Z", status: "some updated status", title: "some updated title"}
  @invalid_attrs %{description: nil, end_date: nil, item_number: nil, list_type: nil, ownership: nil, start_date: nil, status: nil, title: nil}

  def fixture(:to_do) do
    {:ok, to_do} = ToDos.create_to_do(@create_attrs)
    to_do
  end

  describe "index" do
    test "lists all to_dos", %{conn: conn} do
      conn = get conn, to_do_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing To dos"
    end
  end

  describe "new to_do" do
    test "renders form", %{conn: conn} do
      conn = get conn, to_do_path(conn, :new)
      assert html_response(conn, 200) =~ "New To do"
    end
  end

  describe "create to_do" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, to_do_path(conn, :create), to_do: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == to_do_path(conn, :show, id)

      conn = get conn, to_do_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show To do"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, to_do_path(conn, :create), to_do: @invalid_attrs
      assert html_response(conn, 200) =~ "New To do"
    end
  end

  describe "edit to_do" do
    setup [:create_to_do]

    test "renders form for editing chosen to_do", %{conn: conn, to_do: to_do} do
      conn = get conn, to_do_path(conn, :edit, to_do)
      assert html_response(conn, 200) =~ "Edit To do"
    end
  end

  describe "update to_do" do
    setup [:create_to_do]

    test "redirects when data is valid", %{conn: conn, to_do: to_do} do
      conn = put conn, to_do_path(conn, :update, to_do), to_do: @update_attrs
      assert redirected_to(conn) == to_do_path(conn, :show, to_do)

      conn = get conn, to_do_path(conn, :show, to_do)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, to_do: to_do} do
      conn = put conn, to_do_path(conn, :update, to_do), to_do: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit To do"
    end
  end

  describe "delete to_do" do
    setup [:create_to_do]

    test "deletes chosen to_do", %{conn: conn, to_do: to_do} do
      conn = delete conn, to_do_path(conn, :delete, to_do)
      assert redirected_to(conn) == to_do_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, to_do_path(conn, :show, to_do)
      end
    end
  end

  defp create_to_do(_) do
    to_do = fixture(:to_do)
    {:ok, to_do: to_do}
  end
end
