defmodule Standup.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias Standup.Accounts.{Credential, User}


  schema "credentials" do
    field :email, :string
    field :password_hash, :string
    field :provider, :string
    field :token, :string
    field :avatar, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, [:email, :password, :password_confirmation, :provider, :token])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 1)
    |> validate_length(:password_confirmation, min: 1)
    |> validate_confirmation(:password)
  end

  @doc false
  def strategy_changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, [:email, :provider, :token, :avatar])
    |> validate_required([:email, :provider, :token])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  @doc false
  def create_changeset(%Credential{} = credential, attrs) do
    credential
    |> changeset(attrs)
    |> validate_password(:password)
    |> put_pass_hash()
  end

  def validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case valid_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  defp valid_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end
  defp valid_password?(_), do: {:error, "The password is too short"}

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
      %{password: password}} = changeset) do
    change(changeset, Comeonin.Bcrypt.add_hash(password))
  end
  defp put_pass_hash(changeset), do: changeset
  
  # def validate_confirmation(changeset, field) do
  #   value = get_field(changeset, field)
  #   confirmation_value = get_field(changeset, :"#{field}_confirmation")
  #   if value != confirmation_value, do: add_error(changeset, :"#{field}_confirmation", "does not match"), else: changeset
  # end


end
