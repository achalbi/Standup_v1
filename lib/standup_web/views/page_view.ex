defmodule StandupWeb.PageView do
  use StandupWeb, :view
  
  alias Standup.Accounts.User

  def current_user_fullname(conn) do
    %User{firstname: firstname, lastname: lastname} = current_user(conn)
    firstname <> " " <> lastname
  end
end
