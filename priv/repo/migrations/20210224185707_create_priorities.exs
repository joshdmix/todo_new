defmodule Todo.Repo.Migrations.CreatePriorities do
  use Ecto.Migration

  def change do
    create table(:priorities) do
      add :name, :string

      timestamps()
    end

    create unique_index(:priorities, [:name])
  end
end
