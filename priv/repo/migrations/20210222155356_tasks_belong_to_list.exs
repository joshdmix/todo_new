defmodule Todo.Repo.Migrations.TasksBelongToList do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :list_id, references(:lists)
    end
  end
end
