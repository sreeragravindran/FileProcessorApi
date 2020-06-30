defmodule BatchFileProcessor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BatchFileProcessorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BatchFileProcessor.PubSub},
      # Start the Endpoint (http/https)
      BatchFileProcessorWeb.Endpoint,
      BatchFileProcessor.EtsRepo,
      {Task.Supervisor, name: BatchFileProcessor.ProcessorSupervisor},
      BatchFileProcessor.Components.ProcessorHandler
      # Start a worker by calling: BatchFileProcessor.Worker.start_link(arg)
      # {BatchFileProcessor.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BatchFileProcessor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BatchFileProcessorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
