defmodule TwitterWeb.TwitterSocket do
  use Phoenix.Channel

  def join("twitterSocket:*", _message, socket) do
    {:ok, socket}
  end

  def join("twitterSocket:"<> _private_room_id, _params, _socket) do
      {:error, %{reason: "unauthorized"}}
  end

  def handle_in("register_user", payload, socket) do
    GenServer.call(TwitterServer, {:register_user, payload["userName"]})
    {:noreply, socket}
  end

  def handle_in("subscribe_user", payload, socket) do
    GenServer.call(TwitterServer, {:subscribe, payload["userName"], payload["subscriberName"]})
    {:noreply, socket}
 end

 def handle_in("tweet_post", payload, socket) do
  user_list = GenServer.call(TwitterServer, {:tweet_post, payload["userName"], payload["tweetMsg"]})
  IO.puts("******************subscribed_user_list*******************")
  IO.inspect(user_list)
  broadcast socket, "subscribed_tweets", %{userList: user_list,tweetMsg: payload["tweetMsg"], subscribedUser: payload["userName"] }
  {:noreply, socket}
  end

end
