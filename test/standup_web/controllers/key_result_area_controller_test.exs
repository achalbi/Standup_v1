defmodule StandupWeb.KeyResultAreaControllerTest do
  use StandupWeb.ConnCase

  alias Standup.StatusTrack

  @create_attrs %{accountability: "some accountability", effective_communication: true, impediments: "some impediments", ownership: "some ownership", productivity: 120.5, skill: "some skill"}
  @update_attrs %{accountability: "some updated accountability", effective_communication: false, impediments: "some updated impediments", ownership: "some updated ownership", productivity: 456.7, skill: "some updated skill"}
  @invalid_attrs %{accountability: nil, effective_communication: nil, impediments: nil, ownership: nil, productivity: nil, skill: nil}

  def fixture(:key_result_area) do
    {:ok, key_result_area} = StatusTrack.create_key_result_area(@create_attrs)
    key_result_area
  end

  describe "index" do
    test "lists all key_result_areas", %{conn: conn} do
      conn = get conn, key_result_area_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Key result areas"
    end
  end

  describe "new key_result_area" do
    test "renders form", %{conn: conn} do
      conn = get conn, key_result_area_path(conn, :new)
      assert html_response(conn, 200) =~ "New Key result area"
    end
  end

  describe "create key_result_area" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, key_result_area_path(conn, :create), key_result_area: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == key_result_area_path(conn, :show, id)

      conn = get conn, key_result_area_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Key result area"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, key_result_area_path(conn, :create), key_result_area: @invalid_attrs
      assert html_response(conn, 200) =~ "New Key result area"
    end
  end

  describe "edit key_result_area" do
    setup [:create_key_result_area]

    test "renders form for editing chosen key_result_area", %{conn: conn, key_result_area: key_result_area} do
      conn = get conn, key_result_area_path(conn, :edit, key_result_area)
      assert html_response(conn, 200) =~ "Edit Key result area"
    end
  end

  describe "update key_result_area" do
    setup [:create_key_result_area]

    test "redirects when data is valid", %{conn: conn, key_result_area: key_result_area} do
      conn = put conn, key_result_area_path(conn, :update, key_result_area), key_result_area: @update_attrs
      assert redirected_to(conn) == key_result_area_path(conn, :show, key_result_area)

      conn = get conn, key_result_area_path(conn, :show, key_result_area)
      assert html_response(conn, 200) =~ "some updated accountability"
    end

    test "renders errors when data is invalid", %{conn: conn, key_result_area: key_result_area} do
      conn = put conn, key_result_area_path(conn, :update, key_result_area), key_result_area: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Key result area"
    end
  end

  describe "delete key_result_area" do
    setup [:create_key_result_area]

    test "deletes chosen key_result_area", %{conn: conn, key_result_area: key_result_area} do
      conn = delete conn, key_result_area_path(conn, :delete, key_result_area)
      assert redirected_to(conn) == key_result_area_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, key_result_area_path(conn, :show, key_result_area)
      end
    end
  end

  defp create_key_result_area(_) do
    key_result_area = fixture(:key_result_area)
    {:ok, key_result_area: key_result_area}
  end
end
