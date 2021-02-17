defmodule TaskBuilder do
  defmacro __using__(_options) do
    quote do
      alias Todo.{Tasks, Labels}
      alias Todo.Tasks.Task
      import TaskBuilder, only: :functions
    end
  end

  alias Todo.{Tasks, Labels}
  alias Todo.Tasks.Task

  def task do
    task = %Task{}
    task[
      completed: false,
      completed_date: ~U[2021-03-18 21:05:32Z],
      description: "Suspendisse luctus ligula\nvel mi accumsan convallis.\n",
      due_date: ~U[2021-03-11 21:05:32Z],
      id: 42,
      inserted_at: ~N[2021-02-16 21:05:32],
      interval_quantity: 9,
      interval_type: "days",
      label: nil,
      label_id: nil,
      priority: 42,
      start_date: ~U[2021-02-18 21:05:32Z],
      title: "42_title",
      updated_at: ~N[2021-02-16 21:05:32]
    ]
  end

  def task2 do
    task = %Todo.Tasks.Task{}

    task[
      completed: false,
      completed_date: ~U[2021-04-18 21:05:32Z],
      description: "Xander luctus ligula\nvel mi accumsan convallis.\n",
      due_date: ~U[2021-04-11 21:05:32Z],
      id: 44,
      inserted_at: ~N[2021-02-16 21:05:32],
      interval_quantity: 9,
      interval_type: "days",
      label: nil,
      label_id: nil,
      priority: 44,
      start_date: ~U[2021-03-18 21:05:32Z],
      title: "44_title",
      updated_at: ~N[2021-02-16 21:05:32]
    ]
  end

  def task3 do
    %Todo.Tasks.Task{
      completed: false,
      completed_date: ~U[2021-03-18 21:05:32Z],
      description: "Suspendisse luctus ligula\nvel mi accumsan convallis.\n",
      due_date: ~U[2021-03-11 21:05:32Z],
      id: 43,
      inserted_at: ~N[2021-02-16 21:05:32],
      interval_quantity: 10,
      interval_type: "days",
      label: nil,
      label_id: nil,
      priority: 43,
      start_date: ~U[2021-03-03 21:05:32Z],
      title: "43_title",
      updated_at: ~N[2021-02-16 21:05:32]
    }
  end

  def tasks do
    [task(), task2(), task3()]
  end

  def sorting_correctly(original_list, field, returned_list) do
    Enum.sort(original_list, fn task -> task[field] end)
    hd(original_list) == hd(returned_list)
  end
end
