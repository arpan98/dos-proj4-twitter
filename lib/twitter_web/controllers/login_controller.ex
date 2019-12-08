defmodule TwitterWeb.LoginController do
  use TwitterWeb, :controller

  def index(conn, _params) do
    render(conn, "login.html")
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
  
end