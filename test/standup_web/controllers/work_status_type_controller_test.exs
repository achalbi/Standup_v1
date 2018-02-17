defmodule StandupWeb.WorkStatusTypeControllerTest do
  use StandupWeb.ConnCase

  alias Standup.StatusTrack

  @create_attrs %{description: "some description", name: "some name", period: 42}
  @update_attrs %{description: "some updated description", name: "some updated name", period: 43}
  @invalid_attrs %{description: nil, name: nil, period: nil}

  def fixture(:work_status_type) do
    {:ok, work_status_type} = StatusTrack.create_work_status_type(@create_attrs)
    work_status_type
  end

  describe "index" do
    test "lists all work_status_types", %{conn: conn} do
      conn = get conn, work_status_type_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Work status types"
    end
  end

  describe "new work_status_type" do
    test "renders form", %{conn: conn} do
      conn = get conn, work_status_type_path(conn, :new)
      assert html_response(conn, 200) =~ "New Work status type"
    end
  end

  describe "create work_status_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, work_status_type_path(conn, :create), work_status_type: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == work_status_type_path(conn, :show, id)

      conn = get conn, work_status_type_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Work status type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, work_status_type_path(conn, :create), work_status_type: @invalid_attrs
      assert html_response(conn, 200) =~ "New Work status type"
    end
  end

  describe "edit work_status_type" do
    setup [:create_work_status_type]

    test "renders form for editing chosen work_status_type", %{conn: conn, work_status_type: work_status_type} do
      conn = get conn, work_status_type_path(conn, :edit, work_status_type)
      assert html_response(conn, 200) =~ "Edit Work status type"
    end
  end

  describe "update work_status_type" do
    setup [:create_work_status_type]

    test "redirects when data is valid", %{conn: conn, work_status_type: work_status_type} do
      conn = put conn, work_status_type_path(conn, :update, work_status_type), work_status_type: @update_attrs
      assert redirected_to(conn) == work_status_type_path(conn, :show, work_status_type)

      conn = get conn, work_status_type_path(conn, :show, work_status_type)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, work_status_type: work_status_type} do
      conn = put conn, work_status_type_path(conn, :update, work_status_type), work_status_type: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Work status type"
    end
  end

  describe "delete work_status_type" do
    setup [:create_work_status_type]

    test "deletes chosen work_status_type", %{conn: conn, work_status_type: work_status_type} do
      conn = delete conn, work_status_type_path(conn, :delete, work_status_type)
      assert redirected_to(conn) == work_status_type_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, work_status_type_path(conn, :show, work_status_type)
      end
    end
  end

  defp create_work_status_type(_) do
    work_status_type = fixture(:work_status_type)
    {:ok, work_status_type: work_status_type}
  end
end
