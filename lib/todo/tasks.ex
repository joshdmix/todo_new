defmodule Todo.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Todo.{Labels, Priorities}
  alias Todo.Repo
  alias Todo.Store
  alias Todo.Tasks.{Label, Priority, Task}

  def list_tasks do
    Task |> preload(:list) |> Repo.all()
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def create_task!(attrs \\ %{}) do

    Store.put(attrs["start_date"], attrs)

    task =
      %Task{}
      |> Task.changeset(attrs)
      |> Repo.insert!()

    {:ok, task}
  end

  def update_task(%Task{} = task, attrs) do
    new_task = Map.merge(task, attrs)
    Store.put(new_task.start_date, new_task)

    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def insert_or_update_task(%Task{} = task, attrs) do
    task |> Task.changeset(attrs) |> Repo.insert_or_update()
  end

  def insert_all_tasks(tasks) do
    Repo.insert_all(Task, tasks, %{})
  end

  def delete_task(%Task{} = task) do
    Store.delete(task.start_date)
    Repo.delete(task)
  end

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Toggle completed state on task. Current interface only allows a one-way toggle
  (open -> closed) due to complications of interval copying / task recurrence.

  Once a task is marked as completed, the task is checked for the `repeat` field.
  If `task.repeat` is true, a copy is initiated via `interval_copy/1`.
  """
  def toggle_completed(task_id) do
    task = get_task!(task_id)
    {:ok, updated_task} = update_task(task, %{completed: !task.completed})

    if updated_task.repeat do
      interval_copy(updated_task)
    end
  end

  # Matches on Task's `interval_type` field to determine Timex.shift argument's key
  # (:days, :weeks, or :months).
  defp get_shift_by_interval_type(task) do
    case task.interval_type do
      "days" ->
        %{
          task
          | start_date: task.start_date |> Timex.shift(days: task.interval_quantity),
            due_date: task.due_date |> Timex.shift(days: task.interval_quantity)
        }

      "weeks" ->
        %{
          task
          | start_date: task.start_date |> Timex.shift(weeks: task.interval_quantity),
            due_date: task.due_date |> Timex.shift(weeks: task.interval_quantity)
        }

      "months" ->
        %{
          task
          | start_date: task.start_date |> Timex.shift(months: task.interval_quantity),
            due_date: task.due_date |> Timex.shift(months: task.interval_quantity)
        }
    end
  end

  # creates copy of task on specified interval
  # (based on `task.interval_quantity` and `task.interval_type`)
  defp interval_copy(
         task = %{
           id: parent_id,
           completed: parent_completed
         }
       ) do
    new_task = get_shift_by_interval_type(task)

    if parent_completed do
      insert_copy(:active, new_task, parent_id)
    else
      insert_copy(:inactive, new_task, parent_id)
    end
  end

  defp sort_tasks(sort_direction, sort_term) do
    [{sort_direction, sort_term}]
  end

  defp get_todays_tasks(nil) do
    dynamic([t], true)
  end

  defp get_todays_tasks(today) do
    today_date_only = DateTime.to_date(today)
    dynamic([t], fragment("?::date", t.start_date) == ^today_date_only)
  end

  defp get_completed_tasks(nil) do
    dynamic([t], true)
  end

  defp get_completed_tasks(completed) do
    case completed do
      "Completed" ->
        dynamic([t], t.completed == true)

      _ ->
        dynamic([t], t.completed != true)
    end
  end

  defp get_tasks_by_labels(nil) do
    dynamic([t], true)
  end

  defp get_tasks_by_labels(label) do
    dynamic([t], ^label == t.labels)
  end

  defp get_tasks_by_priority(nil) do
    dynamic([t], true)
  end

  defp get_tasks_by_priority(priority) do
    dynamic([t], t.priority == ^priority)
  end

  @doc """
  All sorting and filtering of tasks are performed here. Each of the arguments
  are used to compose a dynamic query to sort and filter the task list. `cursor_after`
  is used for the pagination library being used, but that is currently a loose end that
  needs to be resolved.
  """
  def get_tasks(
        labels,
        priority,
        completed,
        sort_direction,
        sort_term,
        today,
        cursor_after \\ nil
      ) do
    priority = get_tasks_by_priority(priority)
    labels = get_tasks_by_labels(labels)
    completed = get_completed_tasks(completed)
    sort_tasks = sort_tasks(sort_direction, sort_term)
    todays_tasks = get_todays_tasks(today)

    query =
      from t in Task,
        where: ^priority,
        where: ^labels,
        where: ^completed,
        where: ^todays_tasks,
        order_by: ^sort_tasks

    if cursor_after do
      %{metadata: metadata, entries: entries} =
        Repo.paginate(query,
          after: cursor_after,
          cursor_fields: [{:inserted_at, :asc}, {:id, :asc}],
          limit: 100
        )

      %{entries: entries |> format_tasks(), metadata: metadata}
    else
      %{metadata: metadata, entries: entries} =
        Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 100)

      %{entries: entries |> format_tasks(), metadata: metadata}
    end
  end

  @doc """
  Get all Labels in alphabetical list (the Task / Label association is not currently used)
  """
  def list_alphabetical_labels do
    Label |> Labels.alphabetical() |> Repo.all() |> Enum.map(& &1.name)
  end

  @doc """
  Get all Priorities in alphabetical list (the Task / Priority association is not currently used)
  """
  def list_alphabetical_priorities do
    Priority |> Priorities.alphabetical() |> Repo.all() |> Enum.map(& &1.name)
  end

  # def list_priorities do
  #   Repo.all(from t in Task, select: t.priority) |> Enum.uniq()
  # end

  defp format_tasks(tasks) do
    Enum.map(tasks, &format_dates(&1))
  end

  @doc """
  Get and format today's date.
  """
  def get_todays_date() do
    format_string = "%a %B %d %Y"
    Timex.now() |> Timex.format!(format_string, :strftime)
  end

  @doc """
  Format dates on Task.
  """
  def format_dates(task) do
    format_string = "%a %d %b %Y %k:%M"
    start_date = task.start_date |> Timex.format!(format_string, :strftime)
    due_date = task.due_date |> Timex.format!(format_string, :strftime)
    %{task | start_date: start_date, due_date: due_date}
  end

  defp insert_copy(status, task, parent_id) do
    case status do
      :inactive ->
        %{task | inactive: true, parent_id: parent_id, completed: false, completed_date: nil}
        |> Map.from_struct()
        |> create_task!

      :active ->
        %{task | inactive: false, parent_id: parent_id, completed: false, completed_date: nil}
        |> Map.from_struct()
        |> create_task!
    end
  end
end
