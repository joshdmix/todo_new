defmodule Todo.Repo.Migrations.CreateLabels do
  use Ecto.Migration

  def change do
    create table(:labels) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:labels, [:name])

  end
end
