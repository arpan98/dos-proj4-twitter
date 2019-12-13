defmodule Twitter.Server do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init([]) do
    :ets.new(:registered_users, [:set, :private, :named_table])
    :ets.new(:tweets, [:bag, :private, :named_table])
    :ets.new(:hashtags, [:bag, :private, :named_table])
    :ets.new(:mentions, [:bag, :private, :named_table])
    :ets.new(:subscribers, [:bag, :private, :named_table])
    :ets.new(:subscribed_to, [:bag, :private, :named_table])
    :ets.new(:retweets, [:bag, :private, :named_table])
    {:ok, %{average_tweet_time: 0, num_tweets: 0}}
  end

  # Register user
  def handle_call({:register_user, userId, userPid}, _from, state) do
    ret = ServerFunctions.register_user(userId, userPid)
    {:reply, ret, state}
  end

  # Deregister user
  def handle_call({:delete_user, userId}, _from, state) do
    ret = ServerFunctions.delete_user(userId)
    {:reply, ret, state}
  end

  def handle_call({:login_user, userId}, _, state) do
    ret = ServerFunctions.login(userId)
    {:reply, ret, state}
  end

  def handle_call({:logout_user, userId}, _, state) do
    ret = ServerFunctions.logout(userId)
    {:reply, ret, state}
  end

  def handle_cast({:tweet_post, userId, tweet}, state) do
    # start_time = System.monotonic_time()
    ServerFunctions.tweet(userId, tweet, false)
    # end_time = System.monotonic_time()
    # new_avg = ((state.average_tweet_time * state.num_tweets) + (end_time - start_time)) / (state.num_tweets + 1) |> floor()
    # if state.num_tweets + 1 == 1000*10 do
    #   diff = System.convert_time_unit(new_avg, :native, :microsecond)
    #   IO.puts("Average tweet time = #{diff} us #{System.monotonic_time()}")
    # end
    # new_state = %{state | average_tweet_time: new_avg, num_tweets: state.num_tweets + 1}
    {:noreply, state}
  end

  def handle_cast({:subscribe, userId, otherId}, state) do
    ServerFunctions.subscribe(userId, otherId)
    {:noreply, state}
  end

  def handle_call({:get_subscribed_to, userId}, _from, state) do
    ret = ServerFunctions.get_subscribed_to(userId)
    {:reply, ret, state}
  end

  def handle_call({:get_subscribed_tweets, userId}, _from, state) do
    ret = ServerFunctions.get_subscribed_tweets(userId)
    {:reply, ret, state}
  end

  def handle_cast({:retweet_post, userId, ownerId, tweet}, state) do
    ServerFunctions.retweet(userId, ownerId, tweet)
    {:noreply, state}
  end

  def handle_call({:get_hashtag_tweets, hashtag}, _from, state) do
    ret = ServerFunctions.get_hashtag_tweets(hashtag)
    {:reply, ret, state}
  end

  def handle_call({:get_mentioned_tweets, userId}, _from, state) do
    # start_time = System.monotonic_time()
    # IO.puts("started time #{start_time}")
    ret = ServerFunctions.get_mentioned_tweets(userId)
    # end_time = System.monotonic_time()
    # IO.puts("ended time #{end_time}")
    # diff = System.convert_time_unit(end_time - start_time, :native, :microsecond)
    # IO.puts("Get subscribed tweets time = #{diff} us")
    {:reply, ret, state}
  end
end