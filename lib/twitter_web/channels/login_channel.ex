defmodule TwitterWeb.LoginChannel do
  use Phoenix.Channel

  def join("login", _message, socket) do
    {:ok, socket}
  end

  def handle_in("register", %{"username" => username}, socket) do
    case GenServer.call(TwitterServer, {:register_user, username, self()}, :infinity) do
      {:ok, msg} -> push(socket, "register_result", %{result: msg})
      {:error, reason} -> push(socket, "register_result", %{result: reason})  
    end
    {:noreply, socket}
  end

  def handle_in("login", %{"username" => username}, socket) do
    case GenServer.call(TwitterServer, {:login_user, username}, :infinity) do
      {:ok, msg} -> push(socket, "login_result", %{result: msg})
      {:error, reason} -> push(socket, "login_result", %{result: reason})  
    end
    {:noreply, socket}
  end
end