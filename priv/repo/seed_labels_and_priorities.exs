alias Todo.{Labels, Priorities}

for label <- ~w[Database Logic Queries List UI State Processes] do
    Labels.create_label!(label)
end

for priority <- ~w[High Medium Low] do
    Priorities.create_priority!(priority)
end
