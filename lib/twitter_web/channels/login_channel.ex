defmodule TwitterWeb.LoginChannel do
  use Phoenix.Channel

  def join("login", _message, socket) do
    {:ok, socket}
  end

  def handle_in("register", %{"body" => body}, socket) do
    case GenServer.call(TwitterServer, {:register_user, body, self()}, :infinity) do
      {:ok, msg} -> push(socket, "register_result", %{result: msg})
      {:error, reason} -> push(socket, "register_result", %{result: reason})  
    end
    {:noreply, socket}
  end

end