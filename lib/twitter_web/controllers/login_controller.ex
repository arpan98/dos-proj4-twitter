defmodule TwitterWeb.LoginController do
  use TwitterWeb, :controller

  def index(conn, _params) do
    render(conn, "login.html")
  end
  
end