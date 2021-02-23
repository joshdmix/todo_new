defmodule Todo.Repo.Migrations.AddRepeatBooleanToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :repeat, :boolean
    end
  end
end
