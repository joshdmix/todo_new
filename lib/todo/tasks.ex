defmodule Todo.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Todo.Repo

  alias Todo.Labels
  alias Todo.Tasks.{Label, Task}

  def list_tasks do
    Repo.all(Task)
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def create_task!(attrs \\ %{}) do
   task =  %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert!()
   {:ok, task}
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def get_tasks(labels, priority, completed, sort_direction, sort_term) do
    priority  = get_tasks_by_priority(priority)
    labels = get_tasks_by_labels(labels)
    completed = get_completed_tasks(completed)
    sort_tasks = sort_tasks(sort_direction, sort_term)

    query =
      from t in Task,
        where: ^priority,
        where: ^labels,
        where: ^completed,
        order_by: ^sort_tasks

    IO.inspect(query, label: "query!!!!!")
    Repo.all(query) |> format_tasks()
  end

  def sort_tasks(sort_direction \\ :asc, sort_term \\ :start_date) do
    [{sort_direction, sort_term}]
  end

  def get_completed_tasks(nil) do
    dynamic([t], t.completed == true or t.completed == false)
  end

  def get_completed_tasks(completed) do
    IO.inspect(completed, label: "COMPLETED")
    case completed do
      "Completed" ->
        dynamic([t], t.completed == true)

      _ ->
        dynamic([t], t.completed != true)
    end
  end

  def get_tasks_by_labels(nil) do
    dynamic([t], not is_nil(t.labels))
  end

  def get_tasks_by_labels(label) do
    dynamic([t], ^label == t.labels)
  end

  def get_tasks_by_priority(nil) do
    dynamic([t], not is_nil(t.priority))
  end

  def get_tasks_by_priority(priority) do
    dynamic([t], t.priority == ^priority)
  end

  ###############

  # def get_shift_list(date, interval, repeat_qty, unit) do
  #   repeat_list = 1..repeat_qty |> Enum.to_list()
  #   build_shift_list(repeat_list, [], date, interval, unit)
  # end

  # defp build_shift_list([], date_list, _date, _interval, _unit) do
  #   date_list
  # end

  # defp build_shift_list([_hd | tl], date_list, date, interval, unit) do
  #   shift = [{unit, interval}]
  #   shifted_date = date |> Timex.shift(shift)
  #   build_shift_list(tl, [shifted_date | date_list], shifted_date, interval, unit)
  # end

  def list_alphabetical_labels do
    Label |> Labels.alphabetical() |> Repo.all() |> Enum.map(& &1.name)
  end

  def list_priorities do
    Repo.all(from t in Task, select: t.priority) |> Enum.uniq()
  end

  defp format_tasks(tasks) do
    Enum.map(tasks, &format_dates(&1))
  end

  def format_dates(task) do
    format_string = "%A %d %B %Y %k:%M %z"
    start_date = task.start_date |> Timex.format!(format_string, :strftime)
    due_date = task.due_date |> Timex.format!(format_string, :strftime)
    %{task | start_date: start_date, due_date: due_date}
  end

  def day_copy(task = %{start_date: start_date, due_date: due_date}) do
    %{task | start_date: start_date |> Timex.shift(days: 1), due_date: due_date |> Timex.shift(days: 1)}
  end

  def week_copy(task = %{start_date: start_date, due_date: due_date}) do
    %{task | start_date: start_date |> Timex.shift(weeks: 1), due_date: due_date |> Timex.shift(weeks: 1)}
  end

  def month_copy(task = %{start_date: start_date, due_date: due_date}) do
    %{task | start_date: start_date |> Timex.shift(months: 1), due_date: due_date |> Timex.shift(months: 1)}
  end

end




#
#def create_tasks_on_interval(task, interval, repeat_qty, unit \\ :weeks) do
#   shifted_dates

# end

# def shift_dates(start_date, due_date, interval, repeat_qty) do
#   start_dates
# end

# def get_tasks_by_label(label) do
#   Repo.all(from t in Task, where: ^label in t.labels) |> format_tasks()
# end
#
