defmodule Faciqor.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Faciqor.Repo,
      {DNSCluster, query: Application.get_env(:faciqor, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Faciqor.PubSub},
      {Oban, Application.fetch_env!(:faciqor, Oban)},
      FaciqorWeb.Endpoint,
      {GRPC.Server.Supervisor, endpoint: FaciqorGrpc.Endpoint, port: 50051}
    ]

    opts = [strategy: :one_for_one, name: Faciqor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    FaciqorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
