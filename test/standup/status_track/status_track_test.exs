defmodule Standup.StatusTrackTest do
  use Standup.DataCase

  alias Standup.StatusTrack

  describe "work_statuses" do
    alias Standup.StatusTrack.WorkStatus

    @valid_attrs %{on_date: ~D[2010-04-17], task_summary: "some task_summary", user_name: "some user_name"}
    @update_attrs %{on_date: ~D[2011-05-18], task_summary: "some updated task_summary", user_name: "some updated user_name"}
    @invalid_attrs %{on_date: nil, task_summary: nil, user_name: nil}

    def work_status_fixture(attrs \\ %{}) do
      {:ok, work_status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> StatusTrack.create_work_status()

      work_status
    end

    test "list_work_statuses/0 returns all work_statuses" do
      work_status = work_status_fixture()
      assert StatusTrack.list_work_statuses() == [work_status]
    end

    test "get_work_status!/1 returns the work_status with given id" do
      work_status = work_status_fixture()
      assert StatusTrack.get_work_status!(work_status.id) == work_status
    end

    test "create_work_status/1 with valid data creates a work_status" do
      assert {:ok, %WorkStatus{} = work_status} = StatusTrack.create_work_status(@valid_attrs)
      assert work_status.on_date == ~D[2010-04-17]
      assert work_status.task_summary == "some task_summary"
      assert work_status.user_name == "some user_name"
    end

    test "create_work_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StatusTrack.create_work_status(@invalid_attrs)
    end

    test "update_work_status/2 with valid data updates the work_status" do
      work_status = work_status_fixture()
      assert {:ok, work_status} = StatusTrack.update_work_status(work_status, @update_attrs)
      assert %WorkStatus{} = work_status
      assert work_status.on_date == ~D[2011-05-18]
      assert work_status.task_summary == "some updated task_summary"
      assert work_status.user_name == "some updated user_name"
    end

    test "update_work_status/2 with invalid data returns error changeset" do
      work_status = work_status_fixture()
      assert {:error, %Ecto.Changeset{}} = StatusTrack.update_work_status(work_status, @invalid_attrs)
      assert work_status == StatusTrack.get_work_status!(work_status.id)
    end

    test "delete_work_status/1 deletes the work_status" do
      work_status = work_status_fixture()
      assert {:ok, %WorkStatus{}} = StatusTrack.delete_work_status(work_status)
      assert_raise Ecto.NoResultsError, fn -> StatusTrack.get_work_status!(work_status.id) end
    end

    test "change_work_status/1 returns a work_status changeset" do
      work_status = work_status_fixture()
      assert %Ecto.Changeset{} = StatusTrack.change_work_status(work_status)
    end
  end

  describe "tasks" do
    alias Standup.StatusTrack.Task

    @valid_attrs %{notes: "some notes", on_date: "2010-04-17 14:00:00.000000Z", status: "some status", task_number: "some task_number", title: "some title", url: "some url"}
    @update_attrs %{notes: "some updated notes", on_date: "2011-05-18 15:01:01.000000Z", status: "some updated status", task_number: "some updated task_number", title: "some updated title", url: "some updated url"}
    @invalid_attrs %{notes: nil, on_date: nil, status: nil, task_number: nil, title: nil, url: nil}

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> StatusTrack.create_task()

      task
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert StatusTrack.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert StatusTrack.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = StatusTrack.create_task(@valid_attrs)
      assert task.notes == "some notes"
      assert task.on_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert task.status == "some status"
      assert task.task_number == "some task_number"
      assert task.title == "some title"
      assert task.url == "some url"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StatusTrack.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, task} = StatusTrack.update_task(task, @update_attrs)
      assert %Task{} = task
      assert task.notes == "some updated notes"
      assert task.on_date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert task.status == "some updated status"
      assert task.task_number == "some updated task_number"
      assert task.title == "some updated title"
      assert task.url == "some updated url"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = StatusTrack.update_task(task, @invalid_attrs)
      assert task == StatusTrack.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = StatusTrack.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> StatusTrack.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = StatusTrack.change_task(task)
    end
  end

  describe "work_status_types" do
    alias Standup.StatusTrack.WorkStatusType

    @valid_attrs %{description: "some description", name: "some name", period: 42}
    @update_attrs %{description: "some updated description", name: "some updated name", period: 43}
    @invalid_attrs %{description: nil, name: nil, period: nil}

    def work_status_type_fixture(attrs \\ %{}) do
      {:ok, work_status_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> StatusTrack.create_work_status_type()

      work_status_type
    end

    test "list_work_status_types/0 returns all work_status_types" do
      work_status_type = work_status_type_fixture()
      assert StatusTrack.list_work_status_types() == [work_status_type]
    end

    test "get_work_status_type!/1 returns the work_status_type with given id" do
      work_status_type = work_status_type_fixture()
      assert StatusTrack.get_work_status_type!(work_status_type.id) == work_status_type
    end

    test "create_work_status_type/1 with valid data creates a work_status_type" do
      assert {:ok, %WorkStatusType{} = work_status_type} = StatusTrack.create_work_status_type(@valid_attrs)
      assert work_status_type.description == "some description"
      assert work_status_type.name == "some name"
      assert work_status_type.period == 42
    end

    test "create_work_status_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StatusTrack.create_work_status_type(@invalid_attrs)
    end

    test "update_work_status_type/2 with valid data updates the work_status_type" do
      work_status_type = work_status_type_fixture()
      assert {:ok, work_status_type} = StatusTrack.update_work_status_type(work_status_type, @update_attrs)
      assert %WorkStatusType{} = work_status_type
      assert work_status_type.description == "some updated description"
      assert work_status_type.name == "some updated name"
      assert work_status_type.period == 43
    end

    test "update_work_status_type/2 with invalid data returns error changeset" do
      work_status_type = work_status_type_fixture()
      assert {:error, %Ecto.Changeset{}} = StatusTrack.update_work_status_type(work_status_type, @invalid_attrs)
      assert work_status_type == StatusTrack.get_work_status_type!(work_status_type.id)
    end

    test "delete_work_status_type/1 deletes the work_status_type" do
      work_status_type = work_status_type_fixture()
      assert {:ok, %WorkStatusType{}} = StatusTrack.delete_work_status_type(work_status_type)
      assert_raise Ecto.NoResultsError, fn -> StatusTrack.get_work_status_type!(work_status_type.id) end
    end

    test "change_work_status_type/1 returns a work_status_type changeset" do
      work_status_type = work_status_type_fixture()
      assert %Ecto.Changeset{} = StatusTrack.change_work_status_type(work_status_type)
    end
  end

  describe "key_result_areas" do
    alias Standup.StatusTrack.KeyResultArea

    @valid_attrs %{accountability: "some accountability", effective_communication: true, impediments: "some impediments", ownership: "some ownership", productivity: 120.5, skill: "some skill"}
    @update_attrs %{accountability: "some updated accountability", effective_communication: false, impediments: "some updated impediments", ownership: "some updated ownership", productivity: 456.7, skill: "some updated skill"}
    @invalid_attrs %{accountability: nil, effective_communication: nil, impediments: nil, ownership: nil, productivity: nil, skill: nil}

    def key_result_area_fixture(attrs \\ %{}) do
      {:ok, key_result_area} =
        attrs
        |> Enum.into(@valid_attrs)
        |> StatusTrack.create_key_result_area()

      key_result_area
    end

    test "list_key_result_areas/0 returns all key_result_areas" do
      key_result_area = key_result_area_fixture()
      assert StatusTrack.list_key_result_areas() == [key_result_area]
    end

    test "get_key_result_area!/1 returns the key_result_area with given id" do
      key_result_area = key_result_area_fixture()
      assert StatusTrack.get_key_result_area!(key_result_area.id) == key_result_area
    end

    test "create_key_result_area/1 with valid data creates a key_result_area" do
      assert {:ok, %KeyResultArea{} = key_result_area} = StatusTrack.create_key_result_area(@valid_attrs)
      assert key_result_area.accountability == "some accountability"
      assert key_result_area.effective_communication == true
      assert key_result_area.impediments == "some impediments"
      assert key_result_area.ownership == "some ownership"
      assert key_result_area.productivity == 120.5
      assert key_result_area.skill == "some skill"
    end

    test "create_key_result_area/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StatusTrack.create_key_result_area(@invalid_attrs)
    end

    test "update_key_result_area/2 with valid data updates the key_result_area" do
      key_result_area = key_result_area_fixture()
      assert {:ok, key_result_area} = StatusTrack.update_key_result_area(key_result_area, @update_attrs)
      assert %KeyResultArea{} = key_result_area
      assert key_result_area.accountability == "some updated accountability"
      assert key_result_area.effective_communication == false
      assert key_result_area.impediments == "some updated impediments"
      assert key_result_area.ownership == "some updated ownership"
      assert key_result_area.productivity == 456.7
      assert key_result_area.skill == "some updated skill"
    end

    test "update_key_result_area/2 with invalid data returns error changeset" do
      key_result_area = key_result_area_fixture()
      assert {:error, %Ecto.Changeset{}} = StatusTrack.update_key_result_area(key_result_area, @invalid_attrs)
      assert key_result_area == StatusTrack.get_key_result_area!(key_result_area.id)
    end

    test "delete_key_result_area/1 deletes the key_result_area" do
      key_result_area = key_result_area_fixture()
      assert {:ok, %KeyResultArea{}} = StatusTrack.delete_key_result_area(key_result_area)
      assert_raise Ecto.NoResultsError, fn -> StatusTrack.get_key_result_area!(key_result_area.id) end
    end

    test "change_key_result_area/1 returns a key_result_area changeset" do
      key_result_area = key_result_area_fixture()
      assert %Ecto.Changeset{} = StatusTrack.change_key_result_area(key_result_area)
    end
  end

  describe "comments" do
    alias Standup.StatusTrack.Comment

    @valid_attrs %{content: "some content"}
    @update_attrs %{content: "some updated content"}
    @invalid_attrs %{content: nil}

    def comment_fixture(attrs \\ %{}) do
      {:ok, comment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> StatusTrack.create_comment()

      comment
    end

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert StatusTrack.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert StatusTrack.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      assert {:ok, %Comment{} = comment} = StatusTrack.create_comment(@valid_attrs)
      assert comment.content == "some content"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StatusTrack.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      assert {:ok, comment} = StatusTrack.update_comment(comment, @update_attrs)
      assert %Comment{} = comment
      assert comment.content == "some updated content"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = StatusTrack.update_comment(comment, @invalid_attrs)
      assert comment == StatusTrack.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = StatusTrack.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> StatusTrack.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = StatusTrack.change_comment(comment)
    end
  end
end
