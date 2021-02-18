defmodule Todo.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :string
      add :start_date, :utc_datetime
      add :due_date, :utc_datetime
      add :priority, :integer
      add :labels, {:array, :string}
      add :completed, :boolean, default: false, null: false
      add :completed_date, :utc_datetime
      add :interval_type, :string
      add :interval_quantity, :integer

      timestamps()
    end
  end
end
