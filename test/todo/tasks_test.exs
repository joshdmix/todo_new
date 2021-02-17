defmodule Todo.TasksTest do
  use Todo.DataCase

  alias Todo.Tasks

  describe "tasks" do
    alias Todo.Tasks.Task

    @valid_attrs %{completed: true, completed_date: "2010-04-17T14:00:00Z", description: "some description", due_date: "2010-04-17T14:00:00Z", interval_quantity: 42, interval_type: "some interval_type", labels: [], priority: 42, start_date: "2010-04-17T14:00:00Z", title: "some title"}
    @update_attrs %{completed: false, completed_date: "2011-05-18T15:01:01Z", description: "some updated description", due_date: "2011-05-18T15:01:01Z", interval_quantity: 43, interval_type: "some updated interval_type", labels: [], priority: 43, start_date: "2011-05-18T15:01:01Z", title: "some updated title"}
    @invalid_attrs %{completed: nil, completed_date: nil, description: nil, due_date: nil, interval_quantity: nil, interval_type: nil, labels: nil, priority: nil, start_date: nil, title: nil}

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tasks.create_task!()

      task
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "sort_task_by_start_date" do
      task_list = Enum.each([0, 1, 2], &task_fixture(%{start_date: Timex.now() |> Timex.shift(:day, &1)}))
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      IO.inspect(task, label: "HSHSHDHHFSDF")
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task!/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = Tasks.create_task!(@valid_attrs)
      assert task.completed == true
      assert task.completed_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert task.description == "some description"
      assert task.due_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert task.interval_quantity == 42
      assert task.interval_type == "some interval_type"
      assert task.labels == []
      assert task.priority == 42
      assert task.start_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert task.title == "some title"
    end

    test "create_task!/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task!(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Tasks.update_task(task, @update_attrs)
      assert task.completed == false
      assert task.completed_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert task.description == "some updated description"
      assert task.due_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert task.interval_quantity == 43
      assert task.interval_type == "some updated interval_type"
      assert task.labels == []
      assert task.priority == 43
      assert task.start_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert task.title == "some updated title"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end

  end
end
