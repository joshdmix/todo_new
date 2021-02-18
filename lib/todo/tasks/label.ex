defmodule Todo.Tasks.Label do
  use Ecto.Schema
  import Ecto.Changeset

  schema "labels" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(label, attrs) do
    label
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
