defmodule Todo.Repo.Migrations.CreateTasksLabels do
  use Ecto.Migration

  def change do
    create table(:tasks_labels) do
      add :task_id, references(:tasks)
      add :label_id, references(:labels)
    end

    create unique_index(:tasks_labels, [:task_id, :label_id])
  end
end
