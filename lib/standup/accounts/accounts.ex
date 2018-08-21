defmodule Standup.Accounts do
  @moduledoc """
  The Accounts context.
  """
  require Logger
  require Poison
  require IEx

  import Ecto.Query, warn: false

  import Comeonin.Bcrypt

  alias Standup.Repo

  alias Standup.Accounts.{User, Credential, Role, UserRole}
  alias Standup.Galleries
  alias Ueberauth.Auth

  alias Standup.Organizations
  alias Standup.Organizations.{UserOrganization}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    User
    |> Repo.all
    |> Repo.preload(:credential)
    |> Repo.preload(:roles)
    |> Repo.preload(:photo)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:credential)
    |> Repo.preload(:roles)
    |> Repo.preload(:photo)
  end

  def get_user_with_organization!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:organization)
  end
  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    role = Repo.get_by(Role, key: "user")
    result = %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.create_changeset/2)
    |> Ecto.Changeset.put_assoc(:roles, [role])
    |> Repo.insert()

    case result do
      {:ok, user} ->
        case update_profile_photo(attrs) do
          {:ok, photo} ->
            user
            |> Repo.preload(:photo)
            |> User.changeset(attrs)
            |> Ecto.Changeset.put_assoc(:photo, photo)
            |> Repo.update()
          :ok -> result
          _ -> result
        end  
      {:error, _changeset} ->  
        result
    end
  end
      
  
  def create_oauth_user(attrs \\ %{}) do
    role = Repo.get_by(Role, key: "user")
    result = %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.strategy_changeset/2)
    |> Ecto.Changeset.put_assoc(:roles, [role])
    |> Repo.insert()

    case result do
      {:ok, user } ->
        if user.avatar do
          case Cloudex.upload(user.avatar) do
            {:ok, %Cloudex.UploadedImage{public_id: public_id, secure_url: secure_url}} ->
              photo_params = %{public_id: public_id, secure_url: secure_url}
              case Galleries.create_photo(photo_params) do
                {:ok, photo} -> 
                          user
                          |> Repo.preload(:photo)
                          |> User.changeset(attrs)
                          |> Ecto.Changeset.put_assoc(:photo, photo)
                          |> Repo.update()
                {:error, reason} -> {:error, reason}
              end
              _ -> result
            end
        else
          result  
        end
      _ -> result
    end

  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    case update_profile_photo(attrs) do
      {:ok, photo} ->
        user
        |> User.changeset(attrs)
        |> Ecto.Changeset.put_assoc(:photo, photo)
        |> Repo.update()
      :ok -> 
        user
        |> User.changeset(attrs)
        |> Repo.update()
    end
  end

  defp update_profile_photo(attrs) do
    case attrs["photo"] do
      %{"image" => %Plug.Upload{content_type: _type, filename: _filename, path: multipart_path}} ->
        case Cloudex.upload(multipart_path) do
            {:ok, %Cloudex.UploadedImage{public_id: public_id, secure_url: secure_url}} ->
                photo_params = %{public_id: public_id, secure_url: secure_url}
                Galleries.create_photo(photo_params)
        end
      _ -> :ok
    end
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end


  @doc """
  Returns the list of credentials.

  ## Examples

      iex> list_credentials()
      [%Credential{}, ...]

  """
  def list_credentials do
    Repo.all(Credential)
  end

  @doc """
  Gets a single credential.

  Raises `Ecto.NoResultsError` if the Credential does not exist.

  ## Examples

      iex> get_credential!(123)
      %Credential{}

      iex> get_credential!(456)
      ** (Ecto.NoResultsError)

  """
  def get_credential!(id), do: Repo.get!(Credential, id)

  @doc """
  Creates a credential.

  ## Examples

      iex> create_credential(%{field: value})
      {:ok, %Credential{}}

      iex> create_credential(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a credential.

  ## Examples

      iex> update_credential(credential, %{field: new_value})
      {:ok, %Credential{}}

      iex> update_credential(credential, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Credential.

  ## Examples

      iex> delete_credential(credential)
      {:ok, %Credential{}}

      iex> delete_credential(credential)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credential changes.

  ## Examples

      iex> change_credential(credential)
      %Ecto.Changeset{source: %Credential{}}

  """
  def change_credential(%Credential{} = credential) do
    Credential.changeset(credential, %{})
  end

  def strategy_create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.strategy_changeset/2)
    |> Repo.insert()
  end
  

  def authenticate(%Auth{provider: :identity} = auth) do
    query =
      from u in User,
        inner_join: c in assoc(u, :credential),
        where: c.email == ^auth.uid

    Repo.one(query)
    |> Repo.preload(:credential)
    |> authorize(auth)
  end

  def insert_or_update(%Auth{} = auth) do
   # {:ok, basic_info(auth)}
    query =
      from u in User,
        inner_join: c in assoc(u, :credential),
        where: c.email == ^auth.info.email

    case Repo.one(query) do
      nil ->
        credentials_params = %{token: auth.credentials.token, email: auth.info.email, provider: Atom.to_string(auth.provider), avatar: avatar_from_auth(auth)}
        
        %{firstname: auth.info.first_name, lastname: auth.info.last_name, credential: credentials_params, avatar: avatar_from_auth(auth)}
        |> create_oauth_user()
      user ->
        {:ok, user}
    end
  end

  #%{id: auth.uid, name: name_from_auth(auth), avatar: avatar_from_auth(auth)}

    # github does it this way
  defp avatar_from_auth( %{info: %{urls: %{avatar_url: image}} }), do: image

  #facebook does it this way
  defp avatar_from_auth( %{info: %{image: image} }), do: image

  # default case if nothing matches
  defp avatar_from_auth( auth ) do
    Logger.warn auth.provider <> " needs to find an avatar URL!"
    Logger.debug(Poison.encode!(auth))
    nil
  end

  # defp name_from_auth(auth) do
  #   if auth.info.name do
  #     auth.info.name
  #   else
  #     name = [auth.info.first_name, auth.info.last_name]
  #     |> Enum.filter(&(&1 != nil and &1 != ""))

  #     cond do
  #       length(name) == 0 -> auth.info.nickname
  #       true -> Enum.join(name, " ")
  #     end
  #   end
  # end

  defp authorize(nil,_auth), do: {:error, "Invalid username or password"}
  defp authorize(user, auth) do
    case user.credential.password_hash do
      nil -> {:error, "Invalid username or password"}
      _ ->  checkpw(auth.credentials.other.password, user.credential.password_hash)
            |> resolve_authorization(user)
      end
  end

  defp resolve_authorization(false, _user), do: {:error, "Invalid username or password"}
  defp resolve_authorization(true, user), do: {:ok, user}

  def current_user(conn) do
    #id = Plug.Conn.get_session(conn, :current_user_id)
    current_user = Guardian.Plug.current_resource(conn)
    if current_user, do: Standup.Repo.get(User, current_user.id) |> Repo.preload([:credential, :photo, :organizations])
    #id = Guardian.Plug.current_resource(conn)
    #Guardian.Plug.current_resource(conn)
  end

  def logged_in?(conn), do: !!current_user(conn) #Guardian.Plug.authenticated?(conn)

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id), do: Repo.get!(Role, id)

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{source: %Role{}}

  """
  def change_role(%Role{} = role) do
    Role.changeset(role, %{})
  end

  def create_user_role(attrs \\ %{}) do
    %UserRole{}
    |> UserRole.changeset(attrs)
    |> Repo.insert()
  end

  def link_user_to_org!(user) do
    user = user |> Repo.preload([:organizations, :credential])
    [domain] = get_domain_by_user_email(user)
    organization = Organizations.get_organization_from_domain!(domain)
    # one user -> one org logic: will change it soon 
    if organization do
      unless Repo.get_by(UserOrganization, user_id: user.id, organization_id: organization.id) do
        %UserOrganization{}
        |> UserOrganization.changeset(%{})
        |> Ecto.Changeset.put_assoc(:user, user)
        |> Ecto.Changeset.put_assoc(:organization, organization)
        |> Repo.insert()
      end
    end
  end

  def get_domain_by_user_email(user) do
    [_head|domain] = Regex.split(~r{@}, user.credential.email)
    domain
  end

  def get_dashboard(current_user) do
    current_user |> Repo.preload([:credential, organizations: :work_status_types ])
  end
end
