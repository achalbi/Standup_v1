defmodule StandupWeb.JiraController do
  use StandupWeb, :controller
  
  require Logger
  require IEx

  import Standup.Helpers, only: [scrub_get_params: 2]

  plug :scrub_get_params


  def new(conn, _params) do
    setup_all()
    ExJira.OAuth.get_request_token
    url = to_string ExJira.OAuth.get_authorize_url
    Logger.info("oauth_token: ")
    Logger.info(ExJira.Config.get[:oauth_token])
    Logger.info("oauth_token_secret:")
    Logger.info(ExJira.Config.get[:oauth_token_secret])
    Logger.info("URL:")
    Logger.info(url)
    [back_url] = get_req_header(conn, "referer")
    put_session(conn, :back_url, back_url)
    Logger.info(back_url)
   IEx.pry
    conn
    |> redirect(external: url)
  end

  def delete(_conn, _params) do

  end

  def callback(conn, params) do
 
    ExJira.OAuth.get_access_token
    Logger.info("access_token:")
    Logger.info(ExJira.Config.get[:access_token])
    Logger.info("access_token_secret:")
    Logger.info(ExJira.Config.get[:access_token_secret])
    
    url = get_session(conn, :back_url)
    Logger.info("Back_url:")
    Logger.info(url)
    conn
      |> put_flash(:info, "You have successfully logged in")
      |> redirect(external: url)
  end


  defp setup_all do
    oauth_credentials() |> ExJira.Config.set
  end

  defp oauth_credentials do
    [
      site: System.get_env("JIRA_SITE"),
      private_key_file: System.get_env("JIRA_CUSTOMER_SECRET"),
      consumer_key:  System.get_env("JIRA_CUSTOMER_KEY")
    ]
  end

end