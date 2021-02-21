defmodule TodoWeb.TaskLive.FormComponent do
  use TodoWeb, :live_component

  alias Todo.Tasks

  @impl true
  def update(%{task: task} = assigns, socket) do
    changeset = Tasks.change_task(task)

    socket =
      assign(socket, [
        {:labels_list, Tasks.list_alphabetical_labels()},
        {:priorities, Tasks.list_priorities()}
      ])

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Tasks.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    save_task(socket, socket.assigns.action, task_params)
  end

  defp save_task(socket, :edit, task_params) do
    case Tasks.update_task(socket.assigns.task, task_params) do
      {:ok, task} ->
        create_copies?(:edit, task)

        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_task(socket, :new, task_params) do
    case Tasks.create_task!(task_params) do
      {:ok, task} ->
        create_copies?(:new, task)

        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp create_copies?(:new, task = %{interval_quantity: interval_quantity}) do
    if interval_quantity > 0 do
      Tasks.interval_copy(task)
    end
  end

  defp create_copies?(
         :edit,
         task = %{interval_quantity: interval_quantity, interval_type: interval_type}
       ) do
    original_task = Tasks.get_task!(task.id)

    if interval_quantity != original_task.interval_quantity ||
         interval_type != original_task.interval_type do
      IO.inspect(label: "call tasks interval copy")
      Tasks.interval_copy(task)
    end
  end
end
