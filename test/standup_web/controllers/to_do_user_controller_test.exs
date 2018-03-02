defmodule StandupWeb.ToDoUserControllerTest do
  use StandupWeb.ConnCase

  alias Standup.ToDos

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:to_do_user) do
    {:ok, to_do_user} = ToDos.create_to_do_user(@create_attrs)
    to_do_user
  end

  describe "index" do
    test "lists all to_do_users", %{conn: conn} do
      conn = get conn, to_do_user_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing To do users"
    end
  end

  describe "new to_do_user" do
    test "renders form", %{conn: conn} do
      conn = get conn, to_do_user_path(conn, :new)
      assert html_response(conn, 200) =~ "New To do user"
    end
  end

  describe "create to_do_user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, to_do_user_path(conn, :create), to_do_user: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == to_do_user_path(conn, :show, id)

      conn = get conn, to_do_user_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show To do user"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, to_do_user_path(conn, :create), to_do_user: @invalid_attrs
      assert html_response(conn, 200) =~ "New To do user"
    end
  end

  describe "edit to_do_user" do
    setup [:create_to_do_user]

    test "renders form for editing chosen to_do_user", %{conn: conn, to_do_user: to_do_user} do
      conn = get conn, to_do_user_path(conn, :edit, to_do_user)
      assert html_response(conn, 200) =~ "Edit To do user"
    end
  end

  describe "update to_do_user" do
    setup [:create_to_do_user]

    test "redirects when data is valid", %{conn: conn, to_do_user: to_do_user} do
      conn = put conn, to_do_user_path(conn, :update, to_do_user), to_do_user: @update_attrs
      assert redirected_to(conn) == to_do_user_path(conn, :show, to_do_user)

      conn = get conn, to_do_user_path(conn, :show, to_do_user)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, to_do_user: to_do_user} do
      conn = put conn, to_do_user_path(conn, :update, to_do_user), to_do_user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit To do user"
    end
  end

  describe "delete to_do_user" do
    setup [:create_to_do_user]

    test "deletes chosen to_do_user", %{conn: conn, to_do_user: to_do_user} do
      conn = delete conn, to_do_user_path(conn, :delete, to_do_user)
      assert redirected_to(conn) == to_do_user_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, to_do_user_path(conn, :show, to_do_user)
      end
    end
  end

  defp create_to_do_user(_) do
    to_do_user = fixture(:to_do_user)
    {:ok, to_do_user: to_do_user}
  end
end
