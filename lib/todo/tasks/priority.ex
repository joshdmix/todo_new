defmodule Todo.Tasks.Priority do
  use Ecto.Schema
  import Ecto.Changeset

  schema "priorities" do
    field :name, :string

    many_to_many :tasks, Todo.Tasks.Task, join_through: "tasks_priorities"

    timestamps()
  end

  @doc false
  def changeset(priority, attrs) do
    priority
    |> cast(attrs, [:name])
    |> cast_assoc(:tasks, with: &Todo.Tasks.Task.changeset/2)
    |> validate_required([:name])
  end
end
