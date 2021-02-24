defmodule Todo.Lists.List do
  @moduledoc """
  The multilist concept that would require a List hasn't been implemented yet,
  but once implemented this would be relevant.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :title, :string
    has_many :tasks, Todo.Tasks.Task

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
