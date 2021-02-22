# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Todo.Repo.insert!(%Todo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Todo.{Labels, Tasks}

defmodule SeedRand do
  @gen_task_count 6
  @today Timex.now()

  def range, do: 1..@gen_task_count
  def get_label() do
    list = ~w[Work Home Urgent Medical Leisure Read Hobby]
    Enum.at(list, Enum.random(0..6))
  end

  def get_priority() do
    list = ~w[High Medium Low]
    Enum.at(list, Enum.random(0..2))
  end

  def get_start_date(),
    do: @today |> DateTime.truncate(:second) |> Timex.shift(days: :rand.uniform(20))

  def get_due_date(),
    do:
      @today
      |> Timex.shift(days: 20)
      |> DateTime.truncate(:second)
      |> Timex.shift(days: :rand.uniform(10))
end

Enum.each(SeedRand.range |> Enum.to_list(), fn x ->
  Tasks.create_task!(%{
    completed: false,
    description: """
    Suspendisse luctus ligula
    vel mi accumsan convallis.
    """,
    due_date: SeedRand.get_due_date(),
    start_date: SeedRand.get_start_date(),
    priority: SeedRand.get_priority(),
    # labels: [SeedRand.get_label()],
    labels: SeedRand.get_label(),
    title: "title_#{x}",
    interval_type: "days",
    interval_quantity: :rand.uniform(10),
    completed_date: SeedRand.get_due_date()
  })
end)


Enum.each([
  %{
    completed: false,
    completed_date: nil,
    description: "This contains multiple todo lists ",
    due_date: ~U[2021-02-22 14:07:00Z],
    id: 7,
    inserted_at: ~N[2021-02-22 14:08:15],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Database",
    list_id: nil,
    priority: "Low",
    start_date: ~U[2021-02-22 14:07:00Z],
    title: "Superlist schema / migrations",
    updated_at: ~N[2021-02-22 14:08:15]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "Determine how superlist interacts with list processes, handles restarts",
    due_date: ~U[2021-02-22 14:08:00Z],
    id: 8,
    inserted_at: ~N[2021-02-22 14:09:33],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Processes",
    list_id: nil,
    priority: "Low",
    start_date: ~U[2021-02-22 14:08:00Z],
    title: "Superlist process",
    updated_at: ~N[2021-02-22 14:09:33]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "store state locally to allow for db sync ",
    due_date: ~U[2021-02-22 14:09:00Z],
    id: 9,
    inserted_at: ~N[2021-02-22 14:10:33],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Processes",
    list_id: nil,
    priority: "High",
    start_date: ~U[2021-02-22 14:09:00Z],
    title: "State storage for single list",
    updated_at: ~N[2021-02-22 14:10:33]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "regularly sync, or trigger event?",
    due_date: ~U[2021-02-22 14:10:00Z],
    id: 10,
    inserted_at: ~N[2021-02-22 14:11:31],
    interval_quantity: 0,
    interval_type: "days",
    labels: "State",
    list_id: nil,
    priority: "Medium",
    start_date: ~U[2021-02-22 14:10:00Z],
    title: "local state / db sync",
    updated_at: ~N[2021-02-22 14:11:31]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "fix association relationships ",
    due_date: ~U[2021-02-22 14:11:00Z],
    id: 11,
    inserted_at: ~N[2021-02-22 14:12:44],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Database",
    list_id: nil,
    priority: "Medium",
    start_date: ~U[2021-02-22 14:11:00Z],
    title: "labels / priorities associations",
    updated_at: ~N[2021-02-22 14:12:44]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "multi label query still exists in Tasks context but was commented out to allow for dynamic query implementation. ",
    due_date: ~U[2021-02-22 14:13:00Z],
    id: 12,
    inserted_at: ~N[2021-02-22 14:14:25],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Queries",
    list_id: nil,
    priority: "Medium",
    start_date: ~U[2021-02-22 14:13:00Z],
    title: "adjust dynamic queries to once again allow multiple label selection / filtering",
    updated_at: ~N[2021-02-22 14:14:25]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "Launch Show / Edit modal",
    due_date: ~U[2021-02-22 14:28:00Z],
    id: 13,
    inserted_at: ~N[2021-02-22 14:29:29],
    interval_quantity: 0,
    interval_type: "days",
    labels: "List",
    list_id: nil,
    priority: "Low",
    start_date: ~U[2021-02-22 14:28:00Z],
    title: "table row clickable",
    updated_at: ~N[2021-02-22 14:29:29]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "Looks horrible",
    due_date: ~U[2021-02-22 14:30:00Z],
    id: 14,
    inserted_at: ~N[2021-02-22 14:30:36],
    interval_quantity: 0,
    interval_type: "days",
    labels: "List",
    list_id: nil,
    priority: "Low",
    start_date: ~U[2021-02-22 14:30:00Z],
    title: "Improve form UI",
    updated_at: ~N[2021-02-22 14:30:36]
  }
], &Tasks.create_task!(&1))

for label <- ~w(Database Logic Queries List UI State Processes) do
  Labels.create_label!(label)
end
