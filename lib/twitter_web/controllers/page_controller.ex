defmodule TwitterWeb.PageController do
  use TwitterWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/login")
  end
end
