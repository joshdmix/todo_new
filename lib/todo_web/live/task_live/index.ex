defmodule TodoWeb.TaskLive.Index do
  use TodoWeb, :live_view

  alias Todo.Tasks
  alias Todo.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        labels: Tasks.list_alphabetical_labels(),
        priorities: Tasks.list_priorities(),
        completed_options: list_completed_options(),
        selected_labels: nil,
        sorted_tasks: nil,
        selected_priority: nil,
        selected_completed: nil,
        sort_direction: :asc,
        send_sort_term: :start_date,
        send_sort_direction: :asc,
        send_labels: nil,
        send_completed: nil,
        send_priority: nil,
        send_today: nil,
        today: Tasks.get_todays_date()
      )


    tasks = get_tasks(socket)
    # tasks = get_tasks(socket)

    # IO.inspect(tasks, label: "MOUNT TASKS")

    {:ok, assign(socket, :tasks, tasks)}
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

  defp get_tasks(socket) do
    IO.inspect(socket.assigns)
    get_tasks2(socket.assigns)

  end


  defp get_tasks2(_assigns = %{
         send_labels: send_labels,
         send_priority: send_priority,
         send_completed: send_completed,
         send_sort_direction: send_sort_direction,
         send_sort_term: send_sort_term,
         send_today: send_today
       }) do
    Tasks.get_tasks(
      send_labels,
      send_priority,
      send_completed,
      send_sort_direction,
      send_sort_term,
      send_today
    )
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}
  end

  ### SORTING
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


    socket =
      assign(socket,
        send_sort_term: value,
        send_sort_direction: :asc
      )

    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}
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

    socket =
      assign(socket,
        send_sort_term: value,
        send_sort_direction: :desc
      )

    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}
  end

  ### SELECT / GET BY...
  @impl true
  def handle_event("select-label", %{"label_val" => value}, socket) do
    selected_labels = value
      # case socket.assigns.selected_labels do
      #   nil -> [value]
      #   _ -> [value | socket.assigns.selected_labels]
      # end

    socket =
      assign(socket,
        send_labels: selected_labels,
        selected_labels: selected_labels
      )

    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}
  end

  @impl true
  def handle_event("select-priority", %{"priority-val" => priority}, socket) do
    socket =
      assign(socket,
        selected_priority: priority,
        send_priority: priority
      )

    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}
  end

  @impl true
  def handle_event(
        "get-completed",
        %{"completed-option" => completed_option},
        socket
  ) do


    socket = assign(socket, selected_completed: completed_option, send_completed: completed_option)

    IO.inspect(completed_option, label: "COMPLETED OPTION")
    IO.inspect(socket, label: "Socket")
    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}
  end

  ### DESELECT

  @impl true
  def handle_event(
        "deselect-priority",
        %{},
        socket
      ) do
    socket =
      assign(socket,
        send_priority: nil,
        selected_priority: nil
      )

    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}
  end

  @impl true
  def handle_event(
        "deselect-label",
    %{"label_val" => _value},
    socket
        # socket = %{assigns: %{selected_labels: selected_labels}}
      ) do
    # selected_labels = selected_labels |> List.delete(value)


    socket =
      assign(socket,
        send_labels: nil,
        selected_labels: nil
      )

    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}

  end

  @impl true
  def handle_event("deselect-completed", %{}, socket) do
    socket =
      assign(socket,
        send_completed: nil,
        selected_completed: nil
      )

    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}
  end

  @impl true
  def handle_event("reset", %{}, socket) do
    socket =
      assign(socket,
        selected_labels: nil,
        selected_priority: nil,
        selected_completed: nil,
        send_labels: nil,
        send_priority: nil,
        send_completed: nil,
        send_sort_term: :start_date,
        send_sort_direction: :asc,
        send_today: nil
      )

    tasks = get_tasks(socket)

    {:noreply, assign(socket, :tasks, tasks)}
  end

  @impl true
  def handle_event("toggle_completed", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    Tasks.update_task(task, %{completed: !task.completed})

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_today", %{}, socket) do
    socket = assign(socket, send_today: Timex.now())
    IO.inspect(socket, label: "show today")
    tasks = get_tasks(socket)


    {:noreply, assign(socket, :tasks, tasks)}
  end

  defp list_completed_options do
    ["Completed", "Open"]
  end
end
