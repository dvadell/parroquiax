defmodule Parroquiax.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ParroquiaxWeb.Telemetry,
      Parroquiax.Repo,
      {DNSCluster, query: Application.get_env(:parroquiax, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Parroquiax.PubSub},
      # Start a worker by calling: Parroquiax.Worker.start_link(arg)
      # {Parroquiax.Worker, arg},
      # Start to serve requests, typically the last entry
      ParroquiaxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Parroquiax.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ParroquiaxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
