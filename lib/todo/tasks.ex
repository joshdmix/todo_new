defmodule Todo.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Todo.Repo

  alias Todo.Tasks.Task
  alias Todo.Tasks.Label
  alias Todo.Labels

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task!(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def list_alphabetical_labels do
    Label |> Labels.alphabetical() |> Repo.all() |> Enum.map(& &1.name)
  end

  def sort_tasks(direction \\ :asc, field \\ :start_date) do
    values = [{direction, field}]
    Repo.all(from t in Task, order_by: ^values) |> format_tasks()
  end

  def get_tasks_by_label(label) do
    Repo.all(from t in Task, where: ^label in t.labels) |> format_tasks()
  end

  def get_tasks_by_labels([]) do
    list_tasks() |> format_tasks()
  end

  def get_tasks_by_labels(labels) do
    query = &Repo.all(from(t in Task, where: ^&1 in t.labels))
    labels |> Enum.map(query) |> List.flatten() |> Enum.uniq() |> format_tasks()
  end


  def get_tasks_by_priority(priority) do
    Repo.all(from t in Task, where: t.priority == ^priority)
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

  # def create_tasks_on_interval(task, interval, repeat_qty, unit \\ :weeks) do
  #   shifted_dates

  # end

  # def shift_dates(start_date, due_date, interval, repeat_qty) do
  #   start_dates
  # end

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
end
