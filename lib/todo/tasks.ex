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
    task =
      %Task{}
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

  ### queries

  def sort_tasks(sort_direction \\ :asc, sort_term \\ :start_date) do
    [{sort_direction, sort_term}]
  end

  def get_todays_tasks(nil) do
    future = Timex.now() |> Timex.shift(years: 1000)
    dynamic([t], t.start_date < ^future)
  end

  def get_todays_tasks(today) do
    IO.inspect(today, label: "GET TODAYS DATES")
    today_date_only = DateTime.to_date(today)
    dynamic([t], fragment("?::date", t.start_date) == ^today_date_only)
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

    IO.inspect(query, label: "query!!!!!")

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

  def get_todays_date() do
    format_string = "%a %B %d %Y"
    Timex.now() |> Timex.format!(format_string, :strftime)
  end

  @spec format_dates(%{
          :due_date =>
            {{integer, pos_integer, pos_integer},
             {non_neg_integer, non_neg_integer, non_neg_integer}
             | {non_neg_integer, non_neg_integer, non_neg_integer, non_neg_integer | {any, any}}}
            | {integer, pos_integer, pos_integer}
            | %{
                :__struct__ => Date | DateTime | NaiveDateTime | Time,
                :calendar => atom,
                optional(:day) => pos_integer,
                optional(:hour) => non_neg_integer,
                optional(:microsecond) => {non_neg_integer, non_neg_integer},
                optional(:minute) => non_neg_integer,
                optional(:month) => pos_integer,
                optional(:second) => non_neg_integer,
                optional(:std_offset) => integer,
                optional(:time_zone) => binary,
                optional(:utc_offset) => integer,
                optional(:year) => integer,
                optional(:zone_abbr) => binary
              },
          :start_date =>
            {{integer, pos_integer, pos_integer},
             {non_neg_integer, non_neg_integer, non_neg_integer}
             | {non_neg_integer, non_neg_integer, non_neg_integer, non_neg_integer | {any, any}}}
            | {integer, pos_integer, pos_integer}
            | %{
                :__struct__ => Date | DateTime | NaiveDateTime | Time,
                :calendar => atom,
                optional(:day) => pos_integer,
                optional(:hour) => non_neg_integer,
                optional(:microsecond) => {non_neg_integer, non_neg_integer},
                optional(:minute) => non_neg_integer,
                optional(:month) => pos_integer,
                optional(:second) => non_neg_integer,
                optional(:std_offset) => integer,
                optional(:time_zone) => binary,
                optional(:utc_offset) => integer,
                optional(:year) => integer,
                optional(:zone_abbr) => binary
              },
          optional(any) => any
        }) :: %{:due_date => binary, :start_date => binary, optional(any) => any}
  def format_dates(task) do
    format_string = "%a %d %b %Y %k:%M"
    start_date = task.start_date |> Timex.format!(format_string, :strftime)
    due_date = task.due_date |> Timex.format!(format_string, :strftime)
    %{task | start_date: start_date, due_date: due_date}
  end

  def interval_copy(
        task = %{
          interval_type: "days",
          interval_quantity: interval_quantity,
          start_date: start_date,
          due_date: due_date
        }
      ) do
    IO.inspect(task, label: "day")

    %{
      task
      | start_date: start_date |> Timex.shift(days: interval_quantity),
        due_date: due_date |> Timex.shift(days: interval_quantity)
    }
    |> Map.from_struct()
    |> IO.inspect(label: "MAP FROM STRUCT")
    |> create_task!
  end

  def interval_copy(
        task = %{
          interval_type: "weeks",
          interval_quantity: interval_quantity,
          start_date: start_date,
          due_date: due_date
        }
      ) do
    IO.inspect(task, label: "week")

    %{
      task
      | start_date: start_date |> Timex.shift(weeks: interval_quantity),
        due_date: due_date |> Timex.shift(weeks: interval_quantity)
    }
    |> Map.from_struct()
    |> create_task!
  end

  def interval_copy(
        task = %{
          interval_type: "months",
          interval_quantity: interval_quantity,
          start_date: start_date,
          due_date: due_date
        }
      ) do
    IO.inspect(task, label: "month")

    %{
      task
      | start_date: start_date |> Timex.shift(months: interval_quantity),
        due_date: due_date |> Timex.shift(months: interval_quantity)
    }
    |> Map.from_struct()
    |> create_task!
  end
end

#
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
