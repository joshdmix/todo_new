# defmodule TodoWeb.TaskLiveTest do
#   use TodoWeb.ConnCase

#   import Phoenix.LiveViewTest

#   alias Todo.Tasks

#   @create_attrs %{completed: true, completed_date: "2010-04-17T14:00:00Z", description: "some description", due_date: "2010-04-17T14:00:00Z", interval_quantity: 42, interval_type: "some interval_type", labels: [], priority: 42, start_date: "2010-04-17T14:00:00Z", title: "some title"}
#   @update_attrs %{completed: false, completed_date: "2011-05-18T15:01:01Z", description: "some updated description", due_date: "2011-05-18T15:01:01Z", interval_quantity: 43, interval_type: "some updated interval_type", labels: [], priority: 43, start_date: "2011-05-18T15:01:01Z", title: "some updated title"}
#   @invalid_attrs %{completed: nil, completed_date: nil, description: nil, due_date: nil, interval_quantity: nil, interval_type: nil, labels: nil, priority: nil, start_date: nil, title: nil}

#   defp fixture(:task) do
#     {:ok, task} = Tasks.create_task(@create_attrs)
#     task
#   end

#   defp create_task(_) do
#     task = fixture(:task)
#     %{task: task}
#   end

#   describe "Index" do
#     setup [:create_task]

#     test "lists all tasks", %{conn: conn, task: task} do
#       {:ok, _index_live, html} = live(conn, Routes.task_index_path(conn, :index))

#       assert html =~ "Listing Tasks"
#       assert html =~ task.description
#     end

#     test "saves new task", %{conn: conn} do
#       {:ok, index_live, _html} = live(conn, Routes.task_index_path(conn, :index))

#       assert index_live |> element("a", "New Task") |> render_click() =~
#                "New Task"

#       assert_patch(index_live, Routes.task_index_path(conn, :new))

#       assert index_live
#              |> form("#task-form", task: @invalid_attrs)
#              |> render_change() =~ "can&apos;t be blank"

#       {:ok, _, html} =
#         index_live
#         |> form("#task-form", task: @create_attrs)
#         |> render_submit()
#         |> follow_redirect(conn, Routes.task_index_path(conn, :index))

#       assert html =~ "Task created successfully"
#       assert html =~ "some description"
#     end

#     test "updates task in listing", %{conn: conn, task: task} do
#       {:ok, index_live, _html} = live(conn, Routes.task_index_path(conn, :index))

#       assert index_live |> element("#task-#{task.id} a", "Edit") |> render_click() =~
#                "Edit Task"

#       assert_patch(index_live, Routes.task_index_path(conn, :edit, task))

#       assert index_live
#              |> form("#task-form", task: @invalid_attrs)
#              |> render_change() =~ "can&apos;t be blank"

#       {:ok, _, html} =
#         index_live
#         |> form("#task-form", task: @update_attrs)
#         |> render_submit()
#         |> follow_redirect(conn, Routes.task_index_path(conn, :index))

#       assert html =~ "Task updated successfully"
#       assert html =~ "some updated description"
#     end

#     test "deletes task in listing", %{conn: conn, task: task} do
#       {:ok, index_live, _html} = live(conn, Routes.task_index_path(conn, :index))

#       assert index_live |> element("#task-#{task.id} a", "Delete") |> render_click()
#       refute has_element?(index_live, "#task-#{task.id}")
#     end
#   end

#   describe "Show" do
#     setup [:create_task]

#     test "displays task", %{conn: conn, task: task} do
#       {:ok, _show_live, html} = live(conn, Routes.task_show_path(conn, :show, task))

#       assert html =~ "Show Task"
#       assert html =~ task.description
#     end

#     test "updates task within modal", %{conn: conn, task: task} do
#       {:ok, show_live, _html} = live(conn, Routes.task_show_path(conn, :show, task))

#       assert show_live |> element("a", "Edit") |> render_click() =~
#                "Edit Task"

#       assert_patch(show_live, Routes.task_show_path(conn, :edit, task))

#       assert show_live
#              |> form("#task-form", task: @invalid_attrs)
#              |> render_change() =~ "can&apos;t be blank"

#       {:ok, _, html} =
#         show_live
#         |> form("#task-form", task: @update_attrs)
#         |> render_submit()
#         |> follow_redirect(conn, Routes.task_show_path(conn, :show, task))

#       assert html =~ "Task updated successfully"
#       assert html =~ "some updated description"
#     end
#   end
# end
