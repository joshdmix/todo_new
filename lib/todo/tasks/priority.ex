defmodule Todo.Tasks.Priority do
  use Ecto.Schema
  import Ecto.Changeset

  schema "priorities" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(priority, attrs) do
    priority
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
