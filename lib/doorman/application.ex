defmodule Doorman.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DoormanWeb.Telemetry,
      Doorman.Repo,
      {DNSCluster, query: Application.get_env(:doorman, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Doorman.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Doorman.Finch},
      # Start a worker by calling: Doorman.Worker.start_link(arg)
      # {Doorman.Worker, arg},
      # Start to serve requests, typically the last entry
      DoormanWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Doorman.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DoormanWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
