defmodule Todo.TasksTest do
  alias Todo.{Repo, Tasks}
  alias Todo.Tasks.Task
  import Ecto.Query
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
      repeat: false,
      priority: "High",
      start_date: ~U[2021-02-18 21:05:32Z],
      title: "42_title",
      updated_at: ~N[2021-02-16 21:05:32]
    }
    @repeat_attrs %{
      completed: false,
      completed_date: ~U[2021-03-18 21:05:32Z],
      description: "Suspendisse luctus ligula\nvel mi accumsan convallis.\n",
      due_date: ~U[2021-03-11 21:05:32Z],
      labels: "Medical",
      inserted_at: ~N[2021-02-16 21:05:32],
      interval_quantity: 1,
      interval_type: "days",
      repeat: true,
      priority: "High",
      start_date: ~U[2021-02-18 21:05:32Z],
      title: "repeat_title",
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
      repeat: false,
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

    def task_fixtures_get_tasks do
      label_fixtures()
      priority_fixtures()
      completed_fixtures()
    end

    def combo_fixtures do
      task = task_fixture(@valid_attrs)
      start_date = fn -> Timex.now() |> Timex.shift(days: Enum.random(1..10)) end

      Enum.each(
        [
          Map.merge(task, %{
            priority: "High",
            labels: "database",
            completed: false,
            start_date: start_date.()
          }),
          Map.merge(task, %{
            priority: "Low",
            labels: "database",
            completed: false,
            start_date: start_date.()
          }),
          Map.merge(task, %{
            priority: "Medium",
            labels: "UI",
            completed: false,
            start_date: start_date.()
          }),
          Map.merge(task, %{
            priority: "Low",
            labels: "logic",
            completed: true,
            start_date: start_date.()
          }),
          Map.merge(task, %{
            priority: "High",
            labels: "queries",
            completed: true,
            start_date: start_date.()
          })
        ],
        fn change -> change |> Map.from_struct() |> Tasks.create_task!() end
      )

      Tasks.delete_task(task)
    end

    def label_fixtures do
      task = task_fixture(@valid_attrs)
      Enum.each(["UI", "database", "queries", "logic"], &update_and_insert(:labels, &1, task))
    end

    def priority_fixtures do
      task = task_fixture(@valid_attrs)
      Enum.each(["High", "Medium", "Low"], &update_and_insert(:priorities, &1, task))
    end

    def completed_fixtures do
      task = task_fixture(@valid_attrs)
      Enum.each([true, false], &update_and_insert(:completed, &1, task))
    end

    def update_and_insert(:labels, value, task) do
      %{task | labels: value} |> Map.from_struct() |> Tasks.create_task!()
    end

    def update_and_insert(:priorities, value, task) do
      %{task | priority: value} |> Map.from_struct() |> Tasks.create_task!()
    end

    def update_and_insert(:completed, value, task) do
      %{task | completed: value} |> Map.from_struct() |> Tasks.create_task!()
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

      assert task.start_date |> Timex.format!("%a %d %b %Y %k:%M", :strftime) ==
               task2.start_date

      assert task.due_date |> Timex.format!("%a %d %b %Y %k:%M", :strftime) ==
               task2.due_date
    end

    test "`list_alphabetical_priorities/1` lists priority options correctly" do
      priorities = Tasks.list_alphabetical_priorities()
      assert priorities == ["High", "Low", "Medium"]
    end

    test "`list_alphabetical_labels/1` lists priority options correctly" do
      labels = Tasks.list_alphabetical_labels()
      assert labels == ["Database", "List", "Logic", "Processes", "Queries", "State", "UI"]
    end

    test "toggle_completed creates new task if repeat is true - day" do
      task = task_fixture(@repeat_attrs)
      Tasks.toggle_completed(task.id)

      [task1, task2] =
        from(t in Task, where: t.title == "repeat_title", order_by: t.id) |> Repo.all()

      assert task1.completed == true
      assert task2.completed == false
      assert task1.completed_date != nil
      assert task2.completed_date == nil
      assert task1.description == task2.description
      assert task1.labels == task2.labels
      assert task.title == task2.title
      assert task1.start_date |> Timex.shift(days: 1) == task2.start_date
      assert task1.due_date |> Timex.shift(days: 1) == task2.due_date
    end

    test "toggle_completed creates new task if repeat is true - week" do
      task = task_fixture(@repeat_attrs)
      Tasks.update_task(task, %{interval_type: "weeks"})
      Tasks.toggle_completed(task.id)

      [task1, task2] =
        from(t in Task, where: t.title == "repeat_title", order_by: t.id) |> Repo.all()

      assert task1.completed == true
      assert task2.completed == false
      assert task1.completed_date != nil
      assert task2.completed_date == nil
      assert task1.description == task2.description
      assert task1.labels == task2.labels
      assert task.title == task2.title
      assert task1.start_date |> Timex.shift(weeks: 1) == task2.start_date
      assert task1.due_date |> Timex.shift(weeks: 1) == task2.due_date
    end

    test "toggle_completed creates new task if repeat is true - month" do
      task = task_fixture(@repeat_attrs)
      Tasks.update_task(task, %{interval_type: "months"})
      Tasks.toggle_completed(task.id)

      [task1, task2] =
        from(t in Task, where: t.title == "repeat_title", order_by: t.id) |> Repo.all()

      assert task1.completed == true
      assert task2.completed == false
      assert task1.completed_date != nil
      assert task2.completed_date == nil
      assert task1.description == task2.description
      assert task1.labels == task2.labels
      assert task.title == task2.title
      assert task1.start_date |> Timex.shift(months: 1) == task2.start_date
      assert task1.due_date |> Timex.shift(months: 1) == task2.due_date
    end

    test "invalid attrs fail changeset" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        task_fixture(@invalid_attrs) |> Tasks.create_task!()
      end
    end

    test "get_tasks - labels" do
      task_fixtures_get_tasks()
      ui = Tasks.get_tasks("UI", nil, nil, :asc, :start_date, nil, nil)
      assert length(ui.entries) == 1
      database = Tasks.get_tasks("database", nil, nil, :asc, :start_date, nil, nil)
      assert length(database.entries) == 1
      queries = Tasks.get_tasks("queries", nil, nil, :asc, :start_date, nil, nil)
      assert length(queries.entries) == 1
      logic = Tasks.get_tasks("logic", nil, nil, :asc, :start_date, nil, nil)
      assert length(logic.entries) == 1
      default = Tasks.get_tasks(nil, nil, nil, :asc, :start_date, nil, nil)
      assert length(default.entries) == 12
    end

    test "get_tasks - completed" do
      task_fixtures_get_tasks()
      false_ = Tasks.get_tasks(nil, nil, false, :asc, :start_date, nil, nil)
      assert length(false_.entries) == 11
      true_ = Tasks.get_tasks(nil, nil, "Completed", :asc, :start_date, nil, nil)
      assert length(true_.entries) == 1
      default = Tasks.get_tasks(nil, nil, nil, :asc, :start_date, nil, nil)
      assert length(default.entries) == 12
    end

    test "get_tasks - priority" do
      task_fixtures_get_tasks()
      high = Tasks.get_tasks(nil, "High", nil, :asc, :start_date, nil, nil)
      assert length(high.entries) == 10
      medium = Tasks.get_tasks(nil, "Medium", nil, :asc, :start_date, nil, nil)
      assert length(medium.entries) == 1
      low = Tasks.get_tasks(nil, "Low", nil, :asc, :start_date, nil, nil)
      assert length(low.entries) == 1
    end

    test "get_tasks - combinations" do
      combo_fixtures()

      database_high_false = Tasks.get_tasks("database", "High", nil, :asc, :start_date, nil, nil)
      database_low_false = Tasks.get_tasks("database", "Low", nil, :asc, :start_date, nil, nil)
      ui_medium_false = Tasks.get_tasks("UI", "Medium", nil, :asc, :start_date, nil, nil)
      logic_low_true = Tasks.get_tasks("logic", "Low", "Completed", :asc, :start_date, nil, nil)

      queries_high_true =
        Tasks.get_tasks("queries", "High", "Completed", :asc, :start_date, nil, nil)

      completed_only = Tasks.get_tasks(nil, nil, "Completed", :asc, :start_date, nil, nil)
      priority_only = Tasks.get_tasks(nil, "High", nil, :asc, :start_date, nil, nil)
      labels_only = Tasks.get_tasks("database", nil, nil, :asc, :start_date, nil, nil)

      Enum.each(
        [
          database_high_false,
          database_low_false,
          ui_medium_false,
          logic_low_true,
          queries_high_true
        ],
        fn task_list ->
          assert length(task_list.entries) == 1
        end
      )

      Enum.each(
        [
          {database_high_false, "database", "High", false},
          {database_low_false, "database", "Low", false},
          {ui_medium_false, "UI", "Medium", false},
          {logic_low_true, "logic", "Low", true},
          {queries_high_true, "queries", "High", true}
        ],
        fn {task_list, label, priority, completed} ->
          assert %{labels: ^label, priority: ^priority, completed: ^completed} =
                   task_list.entries |> List.first()
        end
      )

      Enum.each(
        [
          completed_only,
          priority_only,
          labels_only
        ],
        fn task_list ->
          assert length(task_list.entries) == 2
        end
      )
    end
  end
end
