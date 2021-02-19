defmodule Todo.TasksTest do
  alias Todo.Tasks
  alias Todo.Repo
  use ExUnit.Case
  use Todo.RepoCase

  describe "tasks" do
    @valid_attrs %{
      completed: false,
      completed_date: ~U[2021-03-18 21:05:32Z],
      description: "Suspendisse luctus ligula\nvel mi accumsan convallis.\n",
      due_date: ~U[2021-03-11 21:05:32Z],
      labels: "Medical",
      inserted_at: ~N[2021-02-16 21:05:32],
      interval_quantity: 9,
      interval_type: "days",
      priority: "High",
      start_date: ~U[2021-02-18 21:05:32Z],
      title: "42_title",
      updated_at: ~N[2021-02-16 21:05:32]
    }
    @update_attrs %{
      completed: false,
      completed_date: ~U[2021-04-18 21:05:32Z],
      description: "Xander luctus ligula\nvel mi accumsan convallis.\n",
      due_date: ~U[2021-04-11 21:05:32Z],
      labels: "Work",
      inserted_at: ~N[2021-02-16 21:05:32],
      interval_quantity: 9,
      interval_type: "days",
      priority: "Low",
      start_date: ~U[2021-03-18 21:05:32Z],
      title: "44_title",
      updated_at: ~N[2021-02-16 21:05:32]
    }
    @more_valid_attrs %{
      completed: false,
      completed_date: ~U[2021-04-18 21:05:32Z],
      description: "Xander luctus ligula\nvel mi accumsan convallis.\n",
      due_date: ~U[2021-04-11 21:05:32Z],
      labels: "Work",
      inserted_at: ~N[2021-02-16 21:05:32],
      interval_quantity: 9,
      interval_type: "days",
      priority: "Medium",
      start_date: ~U[2021-03-18 21:05:32Z],
      title: "44_title",
      updated_at: ~N[2021-02-16 21:05:32]
    }
    @invalid_attrs %{
      completed: nil,
      completed_date: nil,
      description: nil,
      due_date: nil,
      id: nil,
      labels: nil,
      inserted_at: nil,
      interval_quantity: nil,
      interval_type: nil,
      priority: nil,
      start_date: nil,
      title: nil,
      updated_at: nil
    }

    def task_fixture(attrs \\ %{}) do
      {:ok, task} = attrs |> Enum.into(@valid_attrs) |> Tasks.create_task!()
      task
    end

    def task_fixtures(params_list) do
      Enum.each(params_list, &task_fixture(&1))
    end

    test "get_task!/1 gets task" do
      task = %Todo.Tasks.Task{id: id} = task_fixture()
      task2 = Tasks.get_task!(id)

      assert task == task2
    end

    test "delete_task!/1 deletes task" do
      task = %Todo.Tasks.Task{id: id} = task_fixture()
      Tasks.delete_task(task)

      assert_raise(Ecto.NoResultsError, fn -> Tasks.get_task!(id) end)

    end

    test "format_dates/1 correctly formats dates" do
      task = task_fixture()
      task2 = Tasks.format_dates(task)

      assert task.start_date |> Timex.format!("%A %d %B %Y %k:%M %z", :strftime) ==
               task2.start_date

      assert task.due_date |> Timex.format!("%A %d %B %Y %k:%M %z", :strftime) == task2.due_date
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "lists priority options correctly" do
      task_fixtures([@valid_attrs, @update_attrs, @more_valid_attrs])
      priorities_from_db_tasks = Tasks.list_priorities() |> Enum.sort()

      priorities_from_tasks =
        Enum.map([@valid_attrs, @update_attrs, @more_valid_attrs], & &1.priority)

      assert priorities_from_db_tasks == priorities_from_tasks
    end

    test "day_copy copies task with updated start and due dates" do
      task = task_fixture()
      task2 = Tasks.day_copy(task)

      assert task.description == task2.description
      assert task.labels == task2.labels
      assert task.completed == task2.completed
      assert task.title == task2.title
      assert task.start_date |> Timex.shift(days: 1) == task2.start_date
      assert task.due_date |> Timex.shift(days: 1) == task2.due_date
    end

    test "week_copy copies task with updated start and due dates" do
      task = task_fixture()
      task2 = Tasks.week_copy(task)

      assert task.description == task2.description
      assert task.labels == task2.labels
      assert task.completed == task2.completed
      assert task.title == task2.title
      assert task.start_date |> Timex.shift(weeks: 1) == task2.start_date
      assert task.due_date |> Timex.shift(weeks: 1) == task2.due_date
    end

    test "month_copy copies task with updated start and due dates" do
      task = task_fixture()
      task2 = Tasks.month_copy(task)

      assert task.description == task2.description
      assert task.labels == task2.labels
      assert task.completed == task2.completed
      assert task.title == task2.title
      assert task.start_date |> Timex.shift(months: 1) == task2.start_date
      assert task.due_date |> Timex.shift(months: 1) == task2.due_date
    end


    test "invalid attrs fail changeset" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        task_fixture(@invalid_attrs) |> Tasks.create_task!()
      end
    end
  end
end
