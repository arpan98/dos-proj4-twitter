defmodule TwitterWeb.HomeController do
  use TwitterWeb, :controller

  def index(conn, _params) do
    render(conn, "home.html")
  end
end