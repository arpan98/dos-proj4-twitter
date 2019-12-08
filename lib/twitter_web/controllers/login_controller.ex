defmodule TwitterWeb.LoginController do
  use TwitterWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :username) do
      nil -> render(conn, "login.html")
      username -> redirect(conn, to: Routes.home_path(conn, :index))
    end
  end

  def existing(conn, %{"session" => %{"username_existing" => username}}) do
    case GenServer.call(TwitterServer, {:login_user, username}, :infinity) do
      {:ok, _msg} -> 
        conn
        |> put_session(:username, username)
        |> put_flash(:info, "Successfully logged in!")
        |> redirect(to: Routes.home_path(conn, :index))
      {:error, reason} -> 
        conn
        |> put_flash(:error, "Username not found! Please sign up.")
        |> render("login.html")
    end
  end

  def new(conn, %{"session" => %{"username_new" => username}}) do
    case GenServer.call(TwitterServer, {:register_user, username, self()}, :infinity) do
      {:ok, _msg} -> 
        conn
        |> put_session(:username, username)
        |> put_flash(:info, "Successfully registered!")
        |> redirect(to: Routes.home_path(conn, :index))
      {:error, reason} -> 
        conn
        |> put_flash(:error, "Username already exists!")
        |> render("login.html")
    end
  end

  def logout(conn, _params) do
    case get_session(conn, :username) do
      nil -> redirect(conn, to: Routes.login_path(conn, :index))
      username -> 
        case GenServer.call(TwitterServer, {:logout_user, username}, :infinity) do
          {:ok, _msg} -> 
            conn
            |> delete_session(:username)
            |> put_flash(:info, "Logged out!")
            |> redirect(to: Routes.login_path(conn, :index))
          {:error, reason} -> 
            conn
            |> put_flash(:error, "Not logged in!")
            |> redirect(to: Routes.login_path(conn, :index))
        end
    end 
  end

  def delete(conn, _params) do
    case get_session(conn, :username) do
      nil -> redirect(conn, to: Routes.login_path(conn, :index))
      username -> 
        GenServer.call(TwitterServer, {:delete_user, username}, :infinity)
        conn
        |> delete_session(:username)
        |> put_flash(:info, "Deleted account!")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end
  
end