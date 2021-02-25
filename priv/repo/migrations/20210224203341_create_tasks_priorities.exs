defmodule Todo.Repo.Migrations.CreateTasksPriorities do
  use Ecto.Migration

  def change do
    create table(:tasks_priorities) do
      add :task_id, references(:tasks)
      add :priority_id, references(:priorities)
    end

    create unique_index(:tasks_priorities, [:task_id, :priority_id])
  end
end
