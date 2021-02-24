defmodule Todo.ListManager do
  use GenServer

  def init(lists) when is_map(lists) do
    {:ok, lists}
  end

  def init(_list), do: {:error, "lists must be a map"}

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, %{}, options)
  end

  def add_list(manager \\ __MODULE__, list) do
    GenServer.call(manager, {:add_list, list})
  end

  def lookup_list_by_title(manager \\ __MODULE__, list_title) do
    GenServer.call(manager, {:lookup_list_by_title, list_title})
  end

  def handle_call({:add_list, list}, _from, lists) do
    new_lists = Map.put(lists, list.title, list)

    {:reply, :ok, new_lists}
  end

  def handle_call({:lookup_list_by_title, list_title}, _from, lists) do
    {:reply, lists[list_title], lists}
  end
end
