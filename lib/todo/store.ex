defmodule Todo.Store do
  @moduledoc """
  Currently this is the main caching module.
  Nothing is being done with the data at this point,
  but will be populated by database at application start,
  and updated on Task addition / update / deletion. If
  database connection is lost, the cache will continue to
  keep state and will update database when connection is restored.
  """
  use GenServer

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
end
