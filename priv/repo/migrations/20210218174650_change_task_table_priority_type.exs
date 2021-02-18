defmodule Todo.Repo.Migrations.ChangeTaskTablePriorityType do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      modify :priority, :string
    end
  end
end
