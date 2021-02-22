defmodule Todo.Repo.Migrations.RemoveSelfRefLists do
  use Ecto.Migration

  def change do
    alter table(:lists) do
      remove :list_id
    end

  end
end
