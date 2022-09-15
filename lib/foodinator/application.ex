defmodule Foodinator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Foodinator.Repo,
      # Start the Telemetry supervisor
      FoodinatorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Foodinator.PubSub},
      # Start the Endpoint (http/https)
      FoodinatorWeb.Endpoint,
      # Start Task Superviser for restaurant processes
      {Task.Supervisor, name: MyApp.TaskSupervisor},
      # Initialize the RabbitMQ Topology
      Foodinator.Queues.Topology
      # Start a worker by calling: Foodinator.Worker.start_link(arg)
      # {Foodinator.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Foodinator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoodinatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
