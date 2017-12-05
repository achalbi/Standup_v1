
defmodule Standup.Guardian do
  use Guardian, otp_app: :standup

  alias Standup.Repo
  alias Standup.Accounts.User
  
  def subject_for_token(resource, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = to_string(resource.id)
    {:ok, sub}
  end
  # def subject_for_token(_, _) do
  #   {:error, :reason_for_error}
  # end
  
  def resource_from_claims(claims) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In `above subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    id = claims["sub"]
    #resource = Standup.get_resource_by_id(id)
    resource = Repo.get(User, id) |> Repo.preload(:credential)
    {:ok,  resource}
  end
  # def resource_from_claims(_claims) do
  #   {:error, :reason_for_error}
  # end
end



  # defmodule Standup.GuardianSerializer do
  #   @behaviour Guardian.Serializer
  
  #   alias Standup.Repo
  #   alias Standup.Accounts.User
  
  #   def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  #   def for_token(_), do: {:error, "Unknown resource type"}
  
  #   def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  #   def from_token(_), do: {:error, "Unknown resource type"}
  # end