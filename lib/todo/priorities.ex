defmodule Todo.Priorities do
  alias Todo.Repo
  alias Todo.Tasks.Priority
  import Ecto.Query

  def create_priority!(name) do
    Repo.insert!(%Priority{name: name}, on_conflict: :nothing)
  end

  def alphabetical(query) do
    from p in query, order_by: p.name
  end
end
