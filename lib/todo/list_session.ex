defmodule ListSession do
  @moduledoc """
  Multiple "Lists" (and the concept of List itself) are not currently implemented,
  but this is the definition of a single List session that would be used once that concept
  is implemented. This is a child of ListManager (user creates new list, a new ListSession
  is added as a child to ListManager).
  """
  def child_spec({list, id}) do
    %{
      id: {__MODULE__, {list.title, id}},
      start: {__MODULE__, :start_link, [{list, id}]},
      restart: :temporary
    }
  end

  def start_link({list, id}) do
    GenServer.start_link(
      __MODULE__,
      {list, id},
      name: via({list.title, id})
    )
  end

  def new_list(list, id) do
    DynamicSupervisor.start_child(Todo.Supervisor.ListSession, {__MODULE__, {list, id}})
  end

  def add_task(list_name, task) do
    GenServer.call(via(list_name), {:add_task, task})
  end

  def remove_task(list_name, task) do
    GenServer.call(via(list_name), {:remove_task, task})
  end

  def remove_task(list_name) do
    GenServer.call(via(list_name), {:get_tasks})
  end

  def via({_title, _id} = name) do
    {
      :via,
      Registry,
      {Todo.Supervisor.ListSession, name}
    }
  end
end
