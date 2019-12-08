defmodule TwitterWeb.HomeController do
  use TwitterWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :username) do
      nil -> redirect(conn, to: Routes.login_path(conn, :index))
      username -> render(conn, "home.html", username: username)
    end
  end
end