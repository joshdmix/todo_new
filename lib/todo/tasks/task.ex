defmodule Todo.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :completed, :boolean, default: false
    field :completed_date, :utc_datetime
    field :description, :string
    field :due_date, :utc_datetime
    field :interval_quantity, :integer

    field :labels, :string
    field :interval_type, :string
    field :priority, :string
    field :start_date, :utc_datetime
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :title,
      :description,
      :start_date,
      :due_date,
      :priority,
      :completed,
      :completed_date,
      :interval_type,
      :interval_quantity,
      :labels
    ])
    |> validate_required([:title, :description, :start_date, :due_date, :priority])
  end
end
