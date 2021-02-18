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
  @today Timex.now()
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

Enum.each(1..100 |> Enum.to_list(), fn x ->
  Tasks.create_task!(%{
    completed: false,
    description: """
    Suspendisse luctus ligula
    vel mi accumsan convallis.
    """,
    due_date: SeedRand.get_due_date(),
    start_date: SeedRand.get_start_date(),
    priority: SeedRand.get_priority(),
    labels: [SeedRand.get_label()],
    title: "title_#{x}",
    interval_type: "days",
    interval_quantity: :rand.uniform(10),
    completed_date: SeedRand.get_due_date()
  })
end)

for label <- ~w(Work Home Urgent Medical Leisure Read Hobby) do
  Labels.create_label!(label)
end
