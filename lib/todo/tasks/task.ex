defmodule Todo.Tasks.Task do
  @moduledoc """
  The basic unit of a todo list (List).
  """
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
    field :labels, :string
    field :parent_id, :integer
    field :priority, :string
    field :repeat, :boolean, default: false
    field :start_date, :utc_datetime
    field :title, :string
    belongs_to :list, Todo.Lists.List

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
      :labels,
      :list_id,
      :parent_id,
      :repeat
    ])
    |> validate_required([:title, :description, :start_date, :due_date, :priority])
  end
end
