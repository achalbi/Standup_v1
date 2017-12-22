defmodule Standup.GalleriesTest do
  use Standup.DataCase

  alias Standup.Galleries

  describe "photos" do
    alias Standup.Galleries.Photo

    @valid_attrs %{public_id: "some public_id", secure_url: "some secure_url"}
    @update_attrs %{public_id: "some updated public_id", secure_url: "some updated secure_url"}
    @invalid_attrs %{public_id: nil, secure_url: nil}

    def photo_fixture(attrs \\ %{}) do
      {:ok, photo} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Galleries.create_photo()

      photo
    end

    test "list_photos/0 returns all photos" do
      photo = photo_fixture()
      assert Galleries.list_photos() == [photo]
    end

    test "get_photo!/1 returns the photo with given id" do
      photo = photo_fixture()
      assert Galleries.get_photo!(photo.id) == photo
    end

    test "create_photo/1 with valid data creates a photo" do
      assert {:ok, %Photo{} = photo} = Galleries.create_photo(@valid_attrs)
      assert photo.public_id == "some public_id"
      assert photo.secure_url == "some secure_url"
    end

    test "create_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Galleries.create_photo(@invalid_attrs)
    end

    test "update_photo/2 with valid data updates the photo" do
      photo = photo_fixture()
      assert {:ok, photo} = Galleries.update_photo(photo, @update_attrs)
      assert %Photo{} = photo
      assert photo.public_id == "some updated public_id"
      assert photo.secure_url == "some updated secure_url"
    end

    test "update_photo/2 with invalid data returns error changeset" do
      photo = photo_fixture()
      assert {:error, %Ecto.Changeset{}} = Galleries.update_photo(photo, @invalid_attrs)
      assert photo == Galleries.get_photo!(photo.id)
    end

    test "delete_photo/1 deletes the photo" do
      photo = photo_fixture()
      assert {:ok, %Photo{}} = Galleries.delete_photo(photo)
      assert_raise Ecto.NoResultsError, fn -> Galleries.get_photo!(photo.id) end
    end

    test "change_photo/1 returns a photo changeset" do
      photo = photo_fixture()
      assert %Ecto.Changeset{} = Galleries.change_photo(photo)
    end
  end
end
