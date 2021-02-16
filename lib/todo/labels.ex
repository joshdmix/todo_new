defmodule Todo.Labels do
  alias Todo.Repo
  alias Todo.Tasks.Label
  import Ecto.Query

  def create_label!(name) do
    Repo.insert!(%Label{name: name}, on_conflict: :nothing)
  end

  def alphabetical(query) do
    from l in query, order_by: l.name
  end
end
