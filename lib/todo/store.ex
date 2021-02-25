defmodule Todo.Store do
  @moduledoc """
  Currently this is the main caching module.
  """
  alias Todo.Tasks
  use GenServer
  @genserver_db_sync_interval 30000

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def put(start_date, task) do
    GenServer.cast(__MODULE__, {:set, start_date, task})
  end

  def get(start_date) do
    GenServer.call(__MODULE__, {:get, start_date})
  end

  def get_all do
    GenServer.call(__MODULE__, {:get_all})
  end

  def delete(start_date) do
    GenServer.cast(__MODULE__, {:remove, start_date})
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  def init(args) do
    initial_state_from_database()
    recurring_database_sync()
    {:ok, Enum.into(args, %{})}
  end

  def handle_cast({:set, start_date, task}, state) do
    {:noreply, Map.put(state, start_date, task)}
  end

  def handle_cast({:remove, start_date}, state) do
    {:noreply, Map.delete(state, start_date)}
  end

  def handle_call({:get, start_date}, _from, state) do
    {:reply, state[start_date], state}
  end

  def handle_call({:get_all}, _from, state) do
    {:reply, state, state}
  end

  ## Helpers

  def initial_state_from_database do
    Tasks.list_tasks() |> Enum.each(&put(&1.start_date, &1))
  end

  def recurring_database_sync() do
    Process.send_after(self(), :sync_database, @genserver_db_sync_interval)
  end

  def database_sync() do
    # get_all()
    GenServer.call(__MODULE__, {:get_all})
    |> Tasks.filter_genserver_name()
    |> Enum.map(fn {_, v} -> v end)
    |> Tasks.insert_all_tasks()
  end
end
