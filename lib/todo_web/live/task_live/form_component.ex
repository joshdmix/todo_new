defmodule TodoWeb.TaskLive.FormComponent do
  use TodoWeb, :live_component

  alias Todo.{Lists, Tasks}

  @impl true
  def update(%{task: task} = assigns, socket) do
    IO.inspect(task, label: "formcomponent update task")
    changeset = Tasks.change_task(task)

    IO.inspect(changeset, label: "Form update")
    socket =
      assign(socket, [
        {:labels_list, Tasks.list_alphabetical_labels()},
        {:priorities, Tasks.list_alphabetical_priorities()},
        {:lists, list_tuples()}
          ])

    IO.inspect(socket, label: "socket")

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
      {:ok, _task} ->
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
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp list_tuples do
    Lists.list_lists() |> Enum.map(fn %{id: id, title: title} -> %{id: id, title: title} end)
  end
end
