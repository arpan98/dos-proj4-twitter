defmodule TwitterWeb.TweetChannel do
  use Phoenix.Channel

  def join("tweets", _message, socket) do
    {:ok, socket}
  end

  intercept ["newtweet"]

  def handle_in("subTo", payload, socket) do
    GenServer.cast(TwitterServer, {:subscribe, socket.assigns.username, payload["otheruser"]})
    subbedTo = GenServer.call(TwitterServer, {:get_subscribed_to, socket.assigns.username})
    {:noreply, socket |> assign(:subbedTo, subbedTo)}
  end

  def handle_out("newtweet", payload, socket) do
    case Enum.member?(socket.assigns.subbedTo, payload["username"]) do
      true -> 
        push(socket, "newtweet", payload)
        {:noreply, socket}
      false -> {:noreply, socket}
    end
  end
end