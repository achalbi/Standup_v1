defmodule StandupWeb.WorkStatusControllerTest do
  use StandupWeb.ConnCase

  alias Standup.StatusTrack

  @create_attrs %{on_date: ~D[2010-04-17], task_summary: "some task_summary", user_name: "some user_name"}
  @update_attrs %{on_date: ~D[2011-05-18], task_summary: "some updated task_summary", user_name: "some updated user_name"}
  @invalid_attrs %{on_date: nil, task_summary: nil, user_name: nil}

  def fixture(:work_status) do
    {:ok, work_status} = StatusTrack.create_work_status(@create_attrs)
    work_status
  end

  describe "index" do
    test "lists all work_statuses", %{conn: conn} do
      conn = get conn, work_status_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Work statuses"
    end
  end

  describe "new work_status" do
    test "renders form", %{conn: conn} do
      conn = get conn, work_status_path(conn, :new)
      assert html_response(conn, 200) =~ "New Work status"
    end
  end

  describe "create work_status" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, work_status_path(conn, :create), work_status: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == work_status_path(conn, :show, id)

      conn = get conn, work_status_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Work status"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, work_status_path(conn, :create), work_status: @invalid_attrs
      assert html_response(conn, 200) =~ "New Work status"
    end
  end

  describe "edit work_status" do
    setup [:create_work_status]

    test "renders form for editing chosen work_status", %{conn: conn, work_status: work_status} do
      conn = get conn, work_status_path(conn, :edit, work_status)
      assert html_response(conn, 200) =~ "Edit Work status"
    end
  end

  describe "update work_status" do
    setup [:create_work_status]

    test "redirects when data is valid", %{conn: conn, work_status: work_status} do
      conn = put conn, work_status_path(conn, :update, work_status), work_status: @update_attrs
      assert redirected_to(conn) == work_status_path(conn, :show, work_status)

      conn = get conn, work_status_path(conn, :show, work_status)
      assert html_response(conn, 200) =~ "some updated task_summary"
    end

    test "renders errors when data is invalid", %{conn: conn, work_status: work_status} do
      conn = put conn, work_status_path(conn, :update, work_status), work_status: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Work status"
    end
  end

  describe "delete work_status" do
    setup [:create_work_status]

    test "deletes chosen work_status", %{conn: conn, work_status: work_status} do
      conn = delete conn, work_status_path(conn, :delete, work_status)
      assert redirected_to(conn) == work_status_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, work_status_path(conn, :show, work_status)
      end
    end
  end

  defp create_work_status(_) do
    work_status = fixture(:work_status)
    {:ok, work_status: work_status}
  end
end
