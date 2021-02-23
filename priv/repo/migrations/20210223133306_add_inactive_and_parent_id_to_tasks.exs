defmodule Todo.Repo.Migrations.AddInactiveAndParentIdToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :inactive, :boolean
      add :parent_id, :integer
    end

  end
end
