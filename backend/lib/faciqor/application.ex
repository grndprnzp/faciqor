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
      {GRPC.Server.Supervisor,
       endpoint: FaciqorGrpc.Endpoint,
       port: 50051,
       start_server: Application.get_env(:grpc, :start_server, Mix.env() != :test)}
    ]

    opts = [strategy: :one_for_one, name: Faciqor.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        if Application.get_env(:grpc, :start_server, Mix.env() != :test) do
          Task.start(fn ->
            Process.sleep(200)
            Faciqor.Media.Storage.ensure_buckets()
          end)
        end

        {:ok, pid}

      other ->
        other
    end
  end

  @impl true
  def config_change(changed, _new, removed) do
    FaciqorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
