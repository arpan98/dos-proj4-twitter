defmodule ServerFunctions do
  def register_user(userId, userPid) do
    case :ets.lookup(:registered_users, userId) do
      [] ->
        :ets.insert(:registered_users, {userId, userPid, true})
        {:ok, "success"}
      default ->
        {:error, "username already exists"}
    end
  end

  def delete_user(userId) do
    :ets.delete(:registered_users, userId)
    {:ok, "success"}
  end

  def login(userId) do
    case :ets.lookup(:registered_users, userId) do
      [user | _] -> 
        {_, userPid, _} = user
        :ets.insert(:registered_users, {userId, userPid, true})
        {:ok, "success"}
      [] -> {:error, "user not found"}
    end
  end

  def logout(userId) do
    case :ets.lookup(:registered_users, userId) do
      [user | _] -> 
        {_, userPid, _} = user
        :ets.insert(:registered_users, {userId, userPid, false})
        {:ok, "success"}
      [] -> {:error, "user not found"}
    end
  end

  def tweet(userId, tweet, live \\ true) do
    time = System.monotonic_time()
    # IO.puts("User #{userId} tweeted '#{tweet}'")
    :ets.insert(:tweets, {userId, tweet, time})
    TwitterWeb.Endpoint.broadcast_from(self(), "tweets", "gottweet", %{"username" => userId, "tweet" => tweet})

    case live do
      true -> 
        tweet_to_subscribers(userId, tweet)
        find_hashtags(tweet) |> insert_hashtags(userId, tweet)
        mentions = find_mentions(tweet)
        insert_mentions(mentions, userId, tweet)
        tweet_to_mentioned(mentions, userId, tweet)
      false ->
        find_hashtags(tweet) |> insert_hashtags(userId, tweet)
        find_mentions(tweet) |> insert_mentions(userId, tweet)
    end
  end

  def subscribe(userId, otherId) do
    if userId != otherId do
      # IO.inspect([userId, "subscribed to", otherId])
      :ets.insert(:subscribers, {otherId, userId})
      :ets.insert(:subscribed_to, {userId, otherId})
    end
  end

  def get_subscribed_to(userId) do
    :ets.lookup(:subscribed_to, userId) |> Enum.map(fn {_, otherId} -> otherId end)
  end

  def get_subscribed_tweets(userId) do
    # IO.inspect([userId, " is subscribed to "])
    :ets.lookup(:subscribed_to, userId) |> Enum.map(fn {_, otherId} -> :ets.lookup(:tweets, otherId) end)
  end

  def retweet(userId, ownerId, tweet, live \\ true) do
    time = System.monotonic_time()
    # IO.puts("User #{userId} retweeted Owner #{ownerId} - '#{tweet}'")
    :ets.insert(:retweets, {userId, ownerId, tweet, time})
    TwitterWeb.Endpoint.broadcast_from(self(), "tweets", "gotretweet", %{"owner" => ownerId, "username" => userId, "tweet" => tweet})
    case live do
      true -> retweet_to_subscribers(userId, ownerId, tweet)
      false -> :nothing
    end
  end

  def get_hashtag_tweets(hashtag) do
    :ets.lookup(:hashtags, hashtag) |> Enum.map(fn {_, ownerId, tweet} ->
      :ets.lookup(:tweets, ownerId) |> Enum.find(fn {_, usertweet, _} -> usertweet == tweet end)
    end)
  end

  def get_mentioned_tweets(userId) do
    :ets.lookup(:mentions, userId) |> Enum.map(fn {_, ownerId, tweet} ->
      :ets.lookup(:tweets, ownerId) |> Enum.find(fn {_, usertweet, _} -> usertweet == tweet end)
    end)
  end

  defp find_hashtags(tweet) do
    Regex.scan(~r/(#[?<hashtag>\w]+)/, tweet)
  end

  defp find_mentions(tweet) do
    Regex.scan(~r/@([?<hashtag>\w]+)/, tweet)
  end

  defp insert_hashtags(hashtags, userId, tweet) do
    hashtags |> Enum.each(fn [_, capture] ->
      :ets.insert(:hashtags, {capture, userId, tweet})
    end)
  end

  defp insert_mentions(mentions, userId, tweet) do
    mentions |> Enum.each(fn [_, capture] ->
      :ets.insert(:mentions, {String.to_integer(capture), userId, tweet})
    end)
  end

  defp tweet_to_mentioned(mentions, userId, tweet) do
    Enum.each(mentions, fn [_, idString] ->
      {_, otherPid, connected} = :ets.lookup(:registered_users, String.to_integer(idString)) |> Enum.at(0)
      case connected do
        true -> GenServer.cast(otherPid, {:receive_tweet, userId, tweet, :mention})
        false -> :nothing  
      end
    end)
  end

  defp tweet_to_subscribers(userId, tweet) do
    :ets.lookup(:subscribers, userId) |> Enum.each(fn {_, otherId} ->
      {_, otherPid, connected} = :ets.lookup(:registered_users, otherId) |> Enum.at(0)
      case connected do
        true -> GenServer.cast(otherPid, {:receive_tweet, userId, tweet, :subscribe})
        false -> :nothing
      end
    end)
  end

  defp retweet_to_subscribers(userId, ownerId, tweet) do
    :ets.lookup(:subscribers, userId) |> Enum.each(fn {_, otherId} ->
      {_, otherPid, connected} = :ets.lookup(:registered_users, otherId) |> Enum.at(0)
      case connected do
        true -> GenServer.cast(otherPid, {:receive_retweet, userId, ownerId, tweet})
        false -> :nothing  
      end
    end)
  end

  def is_user_connected(userId) do
    {_, _, connected} = :ets.lookup(:registered_users, userId) |> Enum.at(0)
    connected
  end
end