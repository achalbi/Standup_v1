defmodule Standup.UserAuthorizer do

  alias Standup.Accounts.User

  def authorize(:edit_user, user_id, %User{} = current_user) do
    if String.to_integer(user_id) == current_user.id do
      :ok 
    else
      {:error, :unauthorized}
    end
  end

#   def authorize(:update, %CMS.Page{}, %User{}) do
#     :ok
#   end
end