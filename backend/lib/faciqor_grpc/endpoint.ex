defmodule FaciqorGrpc.Endpoint do
  use GRPC.Endpoint

  intercept GRPC.Server.Interceptors.Logger
  intercept FaciqorGrpc.Interceptors.Auth

  run FaciqorGrpc.Services.IdentityService
  run FaciqorGrpc.Services.OperationsService
end
