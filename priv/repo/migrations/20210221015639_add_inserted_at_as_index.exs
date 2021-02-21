defmodule Todo.Repo.Migrations.AddInsertedAtAsIndex do
  use Ecto.Migration

  def change do
    create index("tasks", [:inserted_at, :id])
  end
end
