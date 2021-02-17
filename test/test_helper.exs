Code.require_file "support/task_builder.exs", __DIR__
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Todo.Repo, :manual)
