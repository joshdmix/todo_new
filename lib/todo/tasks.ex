defmodule Todo.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Todo.Labels
  alias Todo.Repo
  alias Todo.Store
  alias Todo.Tasks.{Label, Task}

  def list_tasks do
    Repo.all(Task)
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
    IO.inspect(task)
    # Store.put(task.start_date || attrs.start_date, Map.merge(task, attrs))

    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def toggle_completed(task_id) do
    task = get_task!(task_id)
    {:ok, updated_task} = update_task(task, %{completed: !task.completed})

    if updated_task.repeat do
      interval_copy(updated_task)
    end
  end

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

  def interval_copy(
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

  def delete_task(%Task{} = task) do
    Store.delete(task["start_date"])

    Repo.delete(task)
  end

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  ### queries

  defp sort_tasks(sort_direction, sort_term) do
    [{sort_direction, sort_term}]
  end

  defp get_todays_tasks(nil) do
    future = Timex.now() |> Timex.shift(years: 1000)
    dynamic([t], t.start_date < ^future)
  end

  defp get_todays_tasks(today) do
    today_date_only = DateTime.to_date(today)
    dynamic([t], fragment("?::date", t.start_date) == ^today_date_only)
  end

  defp get_completed_tasks(nil) do
    dynamic([t], t.completed == true or t.completed == false)
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
    dynamic([t], not is_nil(t.labels))
  end

  defp get_tasks_by_labels(label) do
    dynamic([t], ^label == t.labels)
  end

  defp get_tasks_by_priority(nil) do
    dynamic([t], not is_nil(t.priority))
  end

  defp get_tasks_by_priority(priority) do
    dynamic([t], t.priority == ^priority)
  end

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

    # assign the `after` cursor to a variable
    # cursor_after = metadata.after
    # return the next 50 posts
    # assign the `before` cursor to a variable
    # cursor_before = metadata.before
    # return the previous 50 posts (if no post was created in between it should be the same list as in our first call to `paginate`)
    # %{entries: entries, metadata: metadata} = Repo.paginate(query, before: cursor_before, cursor_fields: [:inserted_at, :id], limit: 50)
    # return total count
    # NOTE: this will issue a separate `SELECT COUNT(*) FROM table` query to the database.
    # %{entries: entries, metadata: metadata} = Repo.paginate(query, include_total_count: true, cursor_fields: [:inserted_at, :id], limit: 50)

    # Repo.all(query) |> format_tasks()
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

  def get_todays_date() do
    format_string = "%a %B %d %Y"
    Timex.now() |> Timex.format!(format_string, :strftime)
  end

  def format_dates(task) do
    format_string = "%a %d %b %Y %k:%M"
    start_date = task.start_date |> Timex.format!(format_string, :strftime)
    due_date = task.due_date |> Timex.format!(format_string, :strftime)
    %{task | start_date: start_date, due_date: due_date}
  end

  def insert_copy(status, task, parent_id) do
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
