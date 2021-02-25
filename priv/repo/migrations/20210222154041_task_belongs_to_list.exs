defmodule Todo.Repo.Migrations.TaskBelongsToList do
  use Ecto.Migration

  def change do
    alter table(:lists) do
      add :list_id, references(:lists)
    end
  end
end
