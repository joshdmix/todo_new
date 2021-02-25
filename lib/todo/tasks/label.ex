defmodule Todo.Tasks.Label do
  @moduledoc """
  Establishing / using the Label / Task association was part of the early plan but
  ran into some complications so it got pushed to the backburner. Hoping to get this
  reestablished soon.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "labels" do
    field :name, :string

    many_to_many :tasks, Todo.Tasks.Task, join_through: "tasks_labels"

    timestamps()
  end

  @doc false
  def changeset(label, attrs) do
    label
    |> cast(attrs, [:name])
    |> cast_assoc(:tasks, with: &Todo.Tasks.Task.changeset/2)
    |> validate_required([:name])
  end
end
