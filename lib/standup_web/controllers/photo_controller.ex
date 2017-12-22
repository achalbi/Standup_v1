defmodule StandupWeb.PhotoController do
  use StandupWeb, :controller

  alias Standup.Galleries

  def upload(conn, params) do
    case Cloudex.upload(params["upload_photo"]) do
        {:ok, %Cloudex.UploadedImage{public_id: public_id, secure_url: secure_url}} ->
            photo_params = %{"public_id" => public_id, "secure_url" => secure_url}
            case Galleries.create_photo(photo_params) do
            {:ok, _photo} ->
                conn
                |> put_flash(:info, "Photo successfully.")
                |> render(conn, "image.html", public_id: public_id, secure_url: secure_url )
            {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "new.html", changeset: changeset)
            end
        {:error, _reason} ->
            conn
            |> put_flash(:info, "Photo upload unsuccessfully.")
    end
    render conn, "upload.html"
  end
end