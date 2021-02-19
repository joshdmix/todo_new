defmodule Todo.Repo.Migrations.ChangeLabelToStringInTasksTable do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      modify :labels, :string
    end
  end
end
