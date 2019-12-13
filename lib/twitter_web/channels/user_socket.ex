defmodule TwitterWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "tweets", TwitterWeb.TweetChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"username" => username}, socket, _connect_info) do
    case username do
      "undefined" -> 
        IO.inspect("Username not set. Cannot join socket")
        {:ok, socket}
      _ -> 
        IO.inspect("Username set")
        subbedTo = GenServer.call(TwitterServer, {:get_subscribed_to, username})
        socket = socket
          |> assign(:username, username)
          |> assign(:subbedTo, subbedTo)
        {:ok, socket}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     TwitterWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
