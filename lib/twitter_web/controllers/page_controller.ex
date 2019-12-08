defmodule TwitterWeb.PageController do
  use TwitterWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :username) do
      username -> redirect(conn, to: Routes.home_path(conn, :index))
      nil -> redirect(conn, to: Routes.login_path(conn, :index))
    end
  end
end
