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
end
