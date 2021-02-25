defmodule Todo.Tasks.Task do
  @moduledoc """
  The basic unit of a todo list (List).
  """
  alias Todo.Tasks.{Label, Priority}
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :completed, :boolean, default: false
    field :completed_date, :utc_datetime
    field :description, :string
    field :due_date, :utc_datetime
    field :inactive, :boolean, default: false
    field :interval_quantity, :integer
    field :interval_type, :string
    field :parent_id, :integer
    field :priority, :string
    field :repeat, :boolean, default: false
    field :start_date, :utc_datetime
    field :title, :string
    # belongs_to :list, Todo.Lists.List

    many_to_many :labels, Label, join_through: "tasks_labels"

    many_to_many :priorities, Priority, join_through: "tasks_priorities"

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
      :inactive,
      :interval_type,
      :interval_quantity,
      :parent_id,
      :repeat
    ])
    |> cast_assoc(:labels, with: &Label.changeset/2)
    |> cast_assoc(:priorities, with: &Priority.changeset/2)
    |> validate_required([:title, :description, :start_date, :due_date, :priority])
  end
end
