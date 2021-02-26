defmodule Todo.TaskQueries do
  alias Todo.Tasks.Task
  alias Todo.Repo
  import Ecto.Query

  @doc """
  All sorting and filtering of tasks are performed here. Each of the arguments
  are used to compose a dynamic query to sort and filter the task list. `cursor_after`
  is used for the pagination library being used, but that is currently a loose end that
  needs to be resolved.
  """
  def get_tasks(%{
        labels: labels,
        priority: priority,
        completed: completed,
        sort_direction: sort_direction,
        sort_term: sort_term,
        today: today
      }) do
    Task
    |> filter_by_priority(priority)
    |> filter_by_labels(labels)
    |> filter_by_completed(completed)
    |> filter_by_todays_tasks(today)
    |> sort_by(sort_direction, sort_term)
    |> Repo.all()
  end

  def filter_by_priority(query, nil), do: query
  def filter_by_priority(query, priority), do: where(query, [t], t.priority == ^priority)
  def filter_by_labels(query, nil), do: query
  def filter_by_labels(query, label), do: where(query, [t], t.labels == ^label)
  def filter_by_completed(query, nil), do: query
  def filter_by_completed(query, "COMPLETED"), do: where(query, [t], t.completed == true)
  def filter_by_completed(query, _), do: where(query, [t], t.completed == false)
  def filter_by_todays_tasks(query, nil), do: query

  def filter_by_todays_tasks(query, today) do
    today_date_only = DateTime.to_date(today)
    where(query, [t], fragment("?::date", t.start_date) == ^today_date_only)
  end

  def sort_by(query, nil, nil), do: order_by(query, [{:asc, :start_date}])
  def sort_by(query, sort_direction, sort_term), do: order_by(query, [{^sort_direction, ^sort_term}])
end
