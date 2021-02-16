defmodule Todo.Repo.Migrations.AddLabelIdToTask do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :label_id, references(:labels)
    end
  end
end
