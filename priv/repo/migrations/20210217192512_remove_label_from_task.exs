defmodule Todo.Repo.Migrations.RemoveLabelFromTask do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove :label_id, references(:labels)
    end
  end
end
