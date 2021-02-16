defmodule Todo.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :completed, :boolean, default: false
    field :completed_date, :utc_datetime
    field :description, :string
    field :due_date, :utc_datetime
    field :interval_quantity, :integer
    field :interval_type, :string
    field :labels, {:array, :string}
    field :priority, :integer
    field :start_date, :utc_datetime
    field :title, :string

    belongs_to :label, Todo.Tasks.Label

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :start_date, :due_date, :priority, :labels, :completed, :completed_date, :interval_type, :interval_quantity, :label_id])
    |> validate_required([:title, :description, :start_date, :due_date, :priority, :completed])
  end
end
