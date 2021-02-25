defmodule TaskBuilder do
  defmacro __using__(_options) do
    quote do
      alias Todo.Tasks
      alias Todo.Tasks.Task
      import TaskBuilder, only: :functions
    end
  end

  alias Todo.Tasks.Task
  alias Todo.{Labels, Priorities}

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
  @update_attrs %{
    completed: false,
    completed_date: ~U[2021-04-18 21:05:32Z],
    description: "Xander luctus ligula\nvel mi accumsan convallis.\n",
    due_date: ~U[2021-04-11 21:05:32Z],
    labels: "Work",
    inserted_at: ~N[2021-02-16 21:05:32],
    interval_quantity: 9,
    interval_type: "days",
    repeat: false,
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
    repeat: false,
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
    repeat: false,
    priority: nil,
    start_date: nil,
    title: nil,
    updated_at: nil
  }
  for label <- ~w[Database Logic Queries List UI State Processes] do
    Labels.create_label!(label)
  end

  for priority <- ~w[High Medium Low] do
    Priorities.create_priority!(priority)
  end
end
