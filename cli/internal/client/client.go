package client

import (
	"context"
	"fmt"

	v1 "faciqor/pkg/api/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
)

type Factory func(endpoint, token string) (v1.IdentityServiceClient, func() error, error)
type OperationsFactory func(endpoint, token string) (v1.OperationsServiceClient, func() error, error)

func DefaultFactory(endpoint, token string) (v1.IdentityServiceClient, func() error, error) {
	conn, err := grpc.NewClient(
		endpoint,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithUnaryInterceptor(authUnaryInterceptor(token)),
	)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to connect to %s: %w", endpoint, err)
	}

	return v1.NewIdentityServiceClient(conn), conn.Close, nil
}

func DefaultOperationsFactory(endpoint, token string) (v1.OperationsServiceClient, func() error, error) {
	conn, err := grpc.NewClient(
		endpoint,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithUnaryInterceptor(authUnaryInterceptor(token)),
	)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to connect to %s: %w", endpoint, err)
	}

	return v1.NewOperationsServiceClient(conn), conn.Close, nil
}

func authUnaryInterceptor(token string) grpc.UnaryClientInterceptor {
	return func(
		ctx context.Context,
		method string,
		req, reply interface{},
		cc *grpc.ClientConn,
		invoker grpc.UnaryInvoker,
		opts ...grpc.CallOption,
	) error {
		if token != "" {
			ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+token)
		}
		return invoker(ctx, method, req, reply, cc, opts...)
	}
}
