defmodule StandupWeb.LayoutView do
  use StandupWeb, :view

  def title do
    "Standup"
  end

  def current_user_fullname(conn) do
    %Standup.Accounts.User{firstname: firstname, lastname: lastname} = Standup.Accounts.current_user(conn)
    firstname <> " " <> lastname
  end
end
