defmodule Todo.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Todo.Repo

  alias Todo.Tasks.Task
  alias Todo.Tasks.Label
  alias Todo.Labels

  def list_tasks do
    Repo.all(Task)
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def create_task!(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert!()
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
    IO.inspect(label: "HERE")
    IO.inspect(sort_direction, label: "sort direction")
    IO.inspect(sort_term, label: "sort term")

    q1 = get_tasks_by_priority(priority)

    q2 = get_tasks_by_labels(labels)

    q3 = get_completed_tasks(completed)

    IO.inspect(q1, label: "q1")
    IO.inspect(q2, label: "q2")
    IO.inspect(q3, label: "q3")

    if priority == nil do
      if completed == nil do
        if labels == nil do
          Repo.all(from t in Task, order_by: [{^sort_direction, ^sort_term}])
        end
      end
    end

    # IO.inspect(q3)

    # Task |> where()
    # order_by: [sort_direction: sort_term],
    # [
    #   sort_tasks(sort_direction, sort_term),
    #   get_completed_tasks(completed),
    #   get_tasks_by_priority(priority)
    # ]
    # |> IO.inspect(label: "HERE")
    # |> Enum.filter(&(!is_nil(&1)))
    # |> IO.inspect(label: "HERE")
    # |> List.first
    # |> Enum.join(" and ")
    # |> IO.inspect(label: "HERE")
    # |> Repo.all()
  end

  def sort_tasks(sort_direction \\ :asc, sort_term \\ :start_date) do
    values = [{sort_direction, sort_term}]
    # Repo.all(from t in Task, order_by: ^values) |> format_tasks()
    Repo.all(from t in Task, order_by: ^values)
  end

  def get_completed_tasks(nil),
    do: from(t in Task, where: t.completed == true or t.completed == false)

  def get_completed_tasks(completed) do
    IO.inspect(completed, label: "GET COMPLETED TASKS")
    case completed do
      "Completed" ->
        from t in Task, where: t.completed == true

      _ ->
        from t in Task, where: t.completed != true
    end
  end



  # def get_completed_tasks(:true) do
  #   Repo.all(from t in Task, where: t.completed == true)
  # end

  # def get_uncompleted_tasks(:false) do
  #   Repo.all(from t in Task, where: t.completed == false)
  # end

  def get_tasks_by_labels(nil), do: from(t in Task, where: nil not in t.labels)

  def get_tasks_by_labels(label) do
    from t in Task, where: ^label in t.labels
    # query = &Repo.all(from(t in Task, where: ^&1 in t.labels))
    # labels |> Enum.map(query) |> List.flatten() |> Enum.uniq() |> format_tasks()
  end

  def get_tasks_by_priority(nil), do: from(t in Task, where: not is_nil(t.priority))

  def get_tasks_by_priority(priority) do
    from t in Task, where: t.priority == ^priority
  end

  ###############

  def get_shift_list(date, interval, repeat_qty, unit) do
    repeat_list = 1..repeat_qty |> Enum.to_list()
    build_shift_list(repeat_list, [], date, interval, unit)
  end

  defp build_shift_list([], date_list, _date, _interval, _unit) do
    date_list
  end

  defp build_shift_list([_hd | tl], date_list, date, interval, unit) do
    shift = [{unit, interval}]
    shifted_date = date |> Timex.shift(shift)
    build_shift_list(tl, [shifted_date | date_list], shifted_date, interval, unit)
  end

  def list_alphabetical_labels do
    Label |> Labels.alphabetical() |> Repo.all() |> Enum.map(& &1.name)
  end

  def list_priorities do
    Repo.all(from t in Task, select: t.priority) |> Enum.uniq()
  end

  defp format_tasks(tasks) do
    Enum.map(tasks, &format_dates(&1))
  end

  defp format_dates(task) do
    format_string = "%A %d %B %Y %k:%M %z"
    start_date = task.start_date |> Timex.format!(format_string, :strftime)
    due_date = task.due_date |> Timex.format!(format_string, :strftime)
    %{task | start_date: start_date, due_date: due_date}
  end
end

# def create_tasks_on_interval(task, interval, repeat_qty, unit \\ :weeks) do
#   shifted_dates

# end

# def shift_dates(start_date, due_date, interval, repeat_qty) do
#   start_dates
# end

# def get_tasks_by_label(label) do
#   Repo.all(from t in Task, where: ^label in t.labels) |> format_tasks()
# end
#
