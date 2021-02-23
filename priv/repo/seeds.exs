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
  @label_list ~w[Database Logic Queries List UI State Processes]

  def range, do: 1..@gen_task_count

  def get_labels() do
    [get_label(@label_list)]
  end

  def get_label(list \\ @label_list), do: Enum.at(list, Enum.random(0..6))

  def get_priority() do
    list = ~w[High Medium Low]
    Enum.at(list, Enum.random(0..2))
  end

  def get_start_date(),
    do: @today |> DateTime.truncate(:second)

  def get_due_date(),
    do:
      @today
      |> Timex.shift(days: 20)
      |> DateTime.truncate(:second)
      |> Timex.shift(days: :rand.uniform(10))
end

# Enum.each(SeedRand.range |> Enum.to_list(), fn x ->
#   Tasks.create_task!(%{
#     completed: false,
#     description: """
#     Suspendisse luctus ligula
#     vel mi accumsan convallis.
#     """,
#     due_date: SeedRand.get_due_date(),
#     start_date: SeedRand.get_start_date(),
#     priority: SeedRand.get_priority(),
#     # labels: SeedRand.get_label(),
#     labels: SeedRand.get_label(),
#     title: "title_#{x}",
#     interval_type: "days",
#     interval_quantity: :rand.uniform(10),
#     completed_date: SeedRand.get_due_date()
#   })
# end)

Enum.each(
  [
  %{
    completed: false,
    completed_date: nil,
    description: "This contains multiple todo lists ",
    due_date: SeedRand.get_due_date(),
    id: 7,
    inserted_at: ~N[2021-02-22 15:57:42],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Database",
    list_id: nil,
    priority: "Low",
    repeat: false,
    start_date: SeedRand.get_start_date(),
    title: "Superlist schema / migrations",
    updated_at: ~N[2021-02-22 15:57:42]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "Determine how superlist interacts with list processes, handles restarts",
    due_date: SeedRand.get_due_date(),
    id: 8,
    inserted_at: ~N[2021-02-22 15:57:42],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Processes",
    list_id: nil,
    priority: "Low",
    repeat: false,
    start_date: SeedRand.get_start_date(),
    title: "Superlist process",
    updated_at: ~N[2021-02-22 15:57:42]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "store state locally to allow for db sync ",
    due_date: SeedRand.get_due_date(),
    id: 9,
    inserted_at: ~N[2021-02-22 15:57:42],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Processes",
    list_id: nil,
    priority: "High",
    repeat: false,
    start_date: SeedRand.get_start_date(),
    title: "State storage for single list",
    updated_at: ~N[2021-02-22 15:57:42]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "regularly sync, or trigger event?",
    due_date: SeedRand.get_due_date(),
    id: 10,
    inserted_at: ~N[2021-02-22 15:57:42],
    interval_quantity: 0,
    interval_type: "days",
    labels: "State",
    list_id: nil,
    priority: "Medium",
    repeat: false,
    start_date: SeedRand.get_start_date(),
    title: "local state / db sync",
    updated_at: ~N[2021-02-22 15:57:42]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "fix association relationships ",
    due_date: SeedRand.get_due_date(),
    id: 11,
    inserted_at: ~N[2021-02-22 15:57:42],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Database",
    list_id: nil,
    priority: "Medium",
    repeat: false,
    start_date: SeedRand.get_start_date(),
    title: "labels / priorities associations",
    updated_at: ~N[2021-02-22 15:57:42]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "multi label query still exists in Tasks context but was commented out to allow for dynamic query implementation. ",
    due_date: SeedRand.get_due_date(),
    id: 12,
    inserted_at: ~N[2021-02-22 15:57:42],
    interval_quantity: 0,
    interval_type: "days",
    labels: "Queries",
    list_id: nil,
    priority: "Medium",
    repeat: false,
    start_date: SeedRand.get_start_date(),
    title: "adjust dynamic queries to once again allow multiple label selection / filtering",
    updated_at: ~N[2021-02-22 15:57:42]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "Launch Show / Edit modal",
    due_date: SeedRand.get_due_date(),
    id: 13,
    inserted_at: ~N[2021-02-22 15:57:42],
    interval_quantity: 0,
    interval_type: "days",
    labels: "List",
    list_id: nil,
    priority: "Low",
    repeat: false,
    start_date: SeedRand.get_start_date(),
    title: "table row clickable",
    updated_at: ~N[2021-02-22 15:57:42]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "Looks horrible",
    due_date: SeedRand.get_due_date(),
    id: 14,
    inserted_at: ~N[2021-02-22 15:57:42],
    interval_quantity: 0,
    interval_type: "days",
    labels: "List",
    list_id: nil,
    priority: "Low",
    repeat: false,
    start_date: SeedRand.get_start_date(),
    title: "Improve form UI",
    updated_at: ~N[2021-02-22 15:57:42]
  },
  %{
    completed: false,
    completed_date: nil,
    description: "Allow user to customize label list",
    due_date: SeedRand.get_due_date(),
    id: 15,
    inserted_at: ~N[2021-02-22 16:42:43],
    interval_quantity: 0,
    interval_type: "days",
    labels: "List",
    list_id: nil,
    priority: "Low",
    repeat: false,
    start_date: SeedRand.get_start_date(),
    title: "Customizable Labels",
    updated_at: ~N[2021-02-22 16:42:43]
  }
],
  &Tasks.create_task!(&1)
)

for label <- ~w(Database Logic Queries List UI State Processes) do
  Labels.create_label!(label)
end
