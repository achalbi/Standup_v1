defmodule StandupWeb.CommentController do
  use StandupWeb, :controller
  plug Standup.Plugs.CommentAuthorizer

  alias Standup.StatusTrack
  alias Standup.StatusTrack.Comment

  def index(conn, %{"work_status_id" => work_status_id}) do
    comments = StatusTrack.list_comments(work_status_id)
    render(conn, "index.html", comments: comments)
  end

  def new(conn, %{"work_status_id" => work_status_id}) do
    work_status = StatusTrack.get_work_status!(work_status_id)
    changeset = StatusTrack.change_comment(%Comment{})
    render(conn, "new.html", changeset: changeset, work_status: work_status)
  end

  def create(conn, %{"work_status_id" => work_status_id, "comment" => comment_params}) do
    work_status = StatusTrack.get_work_status!(work_status_id)
    case StatusTrack.create_comment(comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: work_status_path(conn, :show, work_status))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, work_status: work_status)
    end
  end

  def show(conn, %{"id" => id}) do
    comment = StatusTrack.get_comment!(id)
    render(conn, "show.html", comment: comment)
  end

  def edit(conn, %{"id" => id}) do
    comment = StatusTrack.get_comment!(id)
    changeset = StatusTrack.change_comment(comment)
    render(conn, "edit.html", comment: comment, changeset: changeset, work_status: comment.work_status)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = StatusTrack.get_comment!(id)
    case StatusTrack.update_comment(comment, comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: work_status_path(conn, :show, comment.work_status))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", comment: comment, changeset: changeset, work_status: comment.work_status)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = StatusTrack.get_comment!(id)
    work_status = comment.work_status
    {:ok, _comment} = StatusTrack.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: work_status_path(conn, :show, work_status))
  end
end
