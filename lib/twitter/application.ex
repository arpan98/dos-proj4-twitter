defmodule Twitter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      TwitterWeb.Endpoint
      # Starts a worker by calling: Twitter.Worker.start_link(arg)
      # {Twitter.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Twitter.Supervisor]

    start_server()

    num_users = 100
    name_prefixes = ["arpan", "krutantak", "sanket", "rishab"]
    simulated_users = start_clients(num_users, name_prefixes)
    register_clients(simulated_users)

    Supervisor.start_link(children, opts)
  end

  def start_server() do
    GenServer.start_link(Twitter.Server, [], name: TwitterServer)
  end

  def start_clients(num, name_prefixes) do
    Enum.map(0..num-1, fn i ->
      username = get_username(i, num, name_prefixes)
      GenServer.start_link(Twitter.Client, [username])
    end)
  end

  def register_clients(users) do
    users |> Enum.map(fn {_, pid} -> 
      GenServer.cast(pid, :register)
    end)
  end

  def get_username(i, num, names) do
    name_prefix = Enum.at(names, div(length(names) * i, num))
    num_suffix = rem(i, ceil(num / length(names))) + 1
    "#{name_prefix}#{num_suffix}"
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
