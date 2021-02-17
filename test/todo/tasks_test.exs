defmodule Todo.TasksTest do
  use Todo.DataCase

  alias Todo.Tasks

  describe "tasks" do
    alias Todo.Tasks.Task

    @valid_attrs %{
      completed: false,
      completed_date: ~U[2021-03-18 21:05:32Z],
      description: "Suspendisse luctus ligula\nvel mi accumsan convallis.\n",
      due_date: ~U[2021-03-11 21:05:32Z],
      id: 42,
      inserted_at: ~N[2021-02-16 21:05:32],
      interval_quantity: 9,
      interval_type: "days",
      label_id: nil,
      priority: 42,
      start_date: ~U[2021-02-18 21:05:32Z],
      title: "42_title",
      updated_at: ~N[2021-02-16 21:05:32]
    }

    @update_attrs %{
      completed: false,
      completed_date: ~U[2021-03-18 21:05:32Z],
      description: "Suspendisse luctus ligula\nvel mi accumsan convallis.\n",
      due_date: ~U[2021-03-11 21:05:32Z],
      id: 42,
      inserted_at: ~N[2021-02-16 21:05:32],
      interval_quantity: 9,
      interval_type: "days",
      label_id: nil,
      priority: 42,
      start_date: ~U[2021-02-18 21:05:32Z],
      title: "42_title",
      updated_at: ~N[2021-02-16 21:05:32]
    }

    @invalid_attrs %{
      completed: nil,
      completed_date: nil,
      description: nil,
      due_date: nil,
      id: nil,
      inserted_at: nil,
      interval_quantity: nil,
      interval_type: nil,
      label_id: nil,
      priority: nil,
      start_date: nil,
      title: nil,
      updated_at: nil
    }

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tasks.create_task!()

      task
    end

    test "sort by priority" do
      a = task_fixture(@valid_attrs)
      b = task_fixture(@update_attrs)
      list = Repo.all(Task)
      IO.inspect(list, label: "list")
    end
  end
end
