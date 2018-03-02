defmodule Standup.ToDosTest do
  use Standup.DataCase

  alias Standup.ToDos

  describe "to_dos" do
    alias Standup.ToDos.ToDo

    @valid_attrs %{description: "some description", end_date: "2010-04-17 14:00:00.000000Z", item_number: "some item_number", list_type: "some list_type", ownership: "some ownership", start_date: "2010-04-17 14:00:00.000000Z", status: "some status", title: "some title"}
    @update_attrs %{description: "some updated description", end_date: "2011-05-18 15:01:01.000000Z", item_number: "some updated item_number", list_type: "some updated list_type", ownership: "some updated ownership", start_date: "2011-05-18 15:01:01.000000Z", status: "some updated status", title: "some updated title"}
    @invalid_attrs %{description: nil, end_date: nil, item_number: nil, list_type: nil, ownership: nil, start_date: nil, status: nil, title: nil}

    def to_do_fixture(attrs \\ %{}) do
      {:ok, to_do} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ToDos.create_to_do()

      to_do
    end

    test "list_to_dos/0 returns all to_dos" do
      to_do = to_do_fixture()
      assert ToDos.list_to_dos() == [to_do]
    end

    test "get_to_do!/1 returns the to_do with given id" do
      to_do = to_do_fixture()
      assert ToDos.get_to_do!(to_do.id) == to_do
    end

    test "create_to_do/1 with valid data creates a to_do" do
      assert {:ok, %ToDo{} = to_do} = ToDos.create_to_do(@valid_attrs)
      assert to_do.description == "some description"
      assert to_do.end_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert to_do.item_number == "some item_number"
      assert to_do.list_type == "some list_type"
      assert to_do.ownership == "some ownership"
      assert to_do.start_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert to_do.status == "some status"
      assert to_do.title == "some title"
    end

    test "create_to_do/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ToDos.create_to_do(@invalid_attrs)
    end

    test "update_to_do/2 with valid data updates the to_do" do
      to_do = to_do_fixture()
      assert {:ok, to_do} = ToDos.update_to_do(to_do, @update_attrs)
      assert %ToDo{} = to_do
      assert to_do.description == "some updated description"
      assert to_do.end_date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert to_do.item_number == "some updated item_number"
      assert to_do.list_type == "some updated list_type"
      assert to_do.ownership == "some updated ownership"
      assert to_do.start_date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert to_do.status == "some updated status"
      assert to_do.title == "some updated title"
    end

    test "update_to_do/2 with invalid data returns error changeset" do
      to_do = to_do_fixture()
      assert {:error, %Ecto.Changeset{}} = ToDos.update_to_do(to_do, @invalid_attrs)
      assert to_do == ToDos.get_to_do!(to_do.id)
    end

    test "delete_to_do/1 deletes the to_do" do
      to_do = to_do_fixture()
      assert {:ok, %ToDo{}} = ToDos.delete_to_do(to_do)
      assert_raise Ecto.NoResultsError, fn -> ToDos.get_to_do!(to_do.id) end
    end

    test "change_to_do/1 returns a to_do changeset" do
      to_do = to_do_fixture()
      assert %Ecto.Changeset{} = ToDos.change_to_do(to_do)
    end
  end

  describe "to_do_users" do
    alias Standup.ToDos.ToDoUser

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def to_do_user_fixture(attrs \\ %{}) do
      {:ok, to_do_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ToDos.create_to_do_user()

      to_do_user
    end

    test "list_to_do_users/0 returns all to_do_users" do
      to_do_user = to_do_user_fixture()
      assert ToDos.list_to_do_users() == [to_do_user]
    end

    test "get_to_do_user!/1 returns the to_do_user with given id" do
      to_do_user = to_do_user_fixture()
      assert ToDos.get_to_do_user!(to_do_user.id) == to_do_user
    end

    test "create_to_do_user/1 with valid data creates a to_do_user" do
      assert {:ok, %ToDoUser{} = to_do_user} = ToDos.create_to_do_user(@valid_attrs)
    end

    test "create_to_do_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ToDos.create_to_do_user(@invalid_attrs)
    end

    test "update_to_do_user/2 with valid data updates the to_do_user" do
      to_do_user = to_do_user_fixture()
      assert {:ok, to_do_user} = ToDos.update_to_do_user(to_do_user, @update_attrs)
      assert %ToDoUser{} = to_do_user
    end

    test "update_to_do_user/2 with invalid data returns error changeset" do
      to_do_user = to_do_user_fixture()
      assert {:error, %Ecto.Changeset{}} = ToDos.update_to_do_user(to_do_user, @invalid_attrs)
      assert to_do_user == ToDos.get_to_do_user!(to_do_user.id)
    end

    test "delete_to_do_user/1 deletes the to_do_user" do
      to_do_user = to_do_user_fixture()
      assert {:ok, %ToDoUser{}} = ToDos.delete_to_do_user(to_do_user)
      assert_raise Ecto.NoResultsError, fn -> ToDos.get_to_do_user!(to_do_user.id) end
    end

    test "change_to_do_user/1 returns a to_do_user changeset" do
      to_do_user = to_do_user_fixture()
      assert %Ecto.Changeset{} = ToDos.change_to_do_user(to_do_user)
    end
  end
end
