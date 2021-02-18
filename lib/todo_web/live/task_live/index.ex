defmodule TodoWeb.TaskLive.Index do
  use TodoWeb, :live_view

  alias Todo.Tasks
  alias Todo.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        tasks: Tasks.sort_tasks(),
        labels: Tasks.list_alphabetical_labels(),
        priorities: Tasks.list_priorities(),
        completed_options: list_completed_options(),
        selected_labels: nil,
        sorted_tasks: nil,
        selected_priority: nil,
        selected_completed: nil
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, Tasks.get_task!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, %Task{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tasks")
    |> assign(:task, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, assign(socket, :tasks, list_tasks())}
  end

  @impl true
  def handle_event("sort", %{"sort_val" => value}, socket) do
    value =
      case value do
        "Title" -> :title
        "Description" -> :description
        "Start" -> :start_date
        "Due" -> :due_date
        "Priority" -> :priority
        "Labels" -> :labels
        "Completed" -> :completed
      end

    {:noreply, assign(socket, {:tasks, Tasks.sort_tasks(:asc, value)}, {:selected_labels, nil})}
  end

  @impl true
  def handle_event("sort-desc", %{"sort_val" => value}, socket) do
    value =
      case value do
        "Title" -> :title
        "Description" -> :description
        "Start" -> :start_date
        "Due" -> :due_date
        "Priority" -> :priority
        "Labels" -> :labels
        "Completed" -> :completed
      end

    {:noreply, assign(socket, {:tasks, Tasks.sort_tasks(:desc, value)}, {:selected_labels, nil})}
  end

  @impl true
  def handle_event("select-label", %{"label_val" => value}, socket) do
    IO.inspect(value, label: "select-label")

    selected_labels =
      case socket.assigns.selected_labels do
        nil -> [value]
        _ -> [value | socket.assigns.selected_labels]
      end

    socket =
      assign(socket,
        tasks: Tasks.get_tasks_by_labels(selected_labels),
        selected_labels: selected_labels
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("select-priority", %{"priority-val" => priority}, socket) do
    socket =
      assign(socket,
        tasks: Tasks.get_tasks_by_priority(priority),
        selected_priority: priority
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "deselect-priority",
        %{},
        socket
      ) do
    socket =
      assign(socket,
        tasks: Tasks.sort_tasks(),
        selected_priority: nil
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "get-completed",
        %{"completed-option" => completed_option},
        socket
  ) do
    IO.inspect(completed_option, label: "Completed Option")

    tasks = case completed_option do
              "Open" -> Tasks.get_uncompleted_tasks()
              "Completed" -> Tasks.get_completed_tasks()
            end

    IO.inspect(tasks)

    socket = assign(socket, tasks: tasks, selected_labels: nil, selected_completed: completed_option)
    {:noreply, socket}
  end


  @impl true
  def handle_event(
        "deselect-label",
        %{"label_val" => value},
        socket = %{assigns: %{selected_labels: selected_labels}}
      ) do
    selected_labels = selected_labels |> List.delete(value)

    socket =
      assign(socket,
        tasks: Tasks.get_tasks_by_labels(selected_labels),
        selected_labels: selected_labels
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("deselect-completed", %{}, socket) do
    socket =
      assign(socket,
        tasks: Tasks.sort_tasks(),
        selected_completed: nil
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", %{}, socket) do
    socket =
      assign(socket, tasks: Tasks.sort_tasks(), selected_labels: nil, selected_priority: nil, selected_completed: nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_completed", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    Tasks.update_task(task, %{completed: !task.completed})

    {:noreply, socket}
  end

  # @impl true
  # def handle_event("show", %{"task" => task}, socket) do
  #   IO.inspect(task, label: "TASK")
  #   {:noreply, live_redirect(socket, to: Routes.task_show_path(socket, :show, task))}
  # end

  defp list_tasks do
    Tasks.list_tasks()
  end

  defp list_completed_options do
    ["Completed", "Open"]
  end

  # defp get_active_labels(labels, selected_labels) do
  #   case selected_labels do
  #     nil -> Tasks.list_alphabetical_labels
  #     _ -> selected_labels
  #   end
  # end
end
