defmodule TwitterWeb.TweetChannel do
  use Phoenix.Channel

  def join("tweets", _message, socket) do
    {:ok, socket}
  end

  intercept ["gottweet", "gotretweet"]

  def handle_in("subTo", payload, socket) do
    GenServer.cast(TwitterServer, {:subscribe, socket.assigns.username, payload["otheruser"]})
    subbedTo = GenServer.call(TwitterServer, {:get_subscribed_to, socket.assigns.username})
    {:noreply, socket |> assign(:subbedTo, subbedTo)}
  end

  def handle_in("tweet", payload, socket) do
    GenServer.cast(TwitterServer, {:tweet_post, socket.assigns.username, payload["tweet"]})
    {:noreply, socket}
  end

  def handle_in("retweet", payload, socket) do
    GenServer.cast(TwitterServer, {:retweet_post, socket.assigns.username, payload["owner"], payload["tweet"]})
    {:noreply, socket}
  end

  def handle_out("gottweet", payload, socket) do
    case {Enum.member?(socket.assigns.subbedTo, payload["username"]), socket.assigns.username == payload["username"]} do
      {true, false} -> 
        push(socket, "gottweet", payload)
        IO.inspect(payload)
        {:noreply, socket}
      {_, true} ->
        push(socket, "selftweet", payload)
        IO.inspect(payload)
        {:noreply, socket}
      _ -> {:noreply, socket}
    end
  end

  def handle_out("gotretweet", payload, socket) do
    push(socket, "gotretweet", payload)
    IO.inspect(payload)
    {:noreply, socket}
  end
end