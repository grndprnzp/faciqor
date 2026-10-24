defmodule FaciqorGrpc.Interceptors.Auth do
  @behaviour GRPC.Server.Interceptor
  require Ash.Query

  @impl true
  def init(opts), do: opts

  @impl true
  def call(req, stream, next, _opts) do
    headers = GRPC.Stream.get_headers(stream)

    with {:ok, raw_token} <- extract_bearer_token(headers),
         {:ok, user} <- verify_pat_and_load_user(raw_token),
         :ok <- check_email_verification_gate(user) do
      # Store authenticated actor in process dictionary / stream assigns for the service handler
      Process.put(:faciqor_current_actor, user)
      next.(req, stream)
    else
      {:error, :unauthenticated, msg} ->
        raise GRPC.RPCError, status: GRPC.Status.unauthenticated(), message: msg

      {:error, :permission_denied, msg} ->
        raise GRPC.RPCError, status: GRPC.Status.permission_denied(), message: msg
    end
  end

  def extract_bearer_token(headers) do
    case Map.get(headers, "authorization") do
      "Bearer " <> token -> {:ok, String.trim(token)}
      _ -> {:error, :unauthenticated, "Missing or invalid authorization Bearer header"}
    end
  end

  def verify_pat_and_load_user(raw_token) do
    token_hash = :crypto.hash(:sha256, raw_token) |> Base.encode16(case: :lower)
    now = DateTime.utc_now()

    query =
      Faciqor.Accounts.ApiToken
      |> Ash.Query.filter(
        token_hash == ^token_hash and is_nil(revoked_at) and
          (is_nil(expires_at) or expires_at > ^now)
      )
      |> Ash.Query.load(user: [:email_verified?, :verification_grace_expired?, :purge_at])

    case Ash.read_one(query, authorize?: false) do
      {:ok, %Faciqor.Accounts.ApiToken{user: user} = api_token} when not is_nil(user) ->
        if is_nil(user.deleted_at) do
          _ =
            api_token
            |> Ash.Changeset.for_update(:touch_last_used, %{}, authorize?: false)
            |> Ash.update()

          {:ok, user}
        else
          {:error, :unauthenticated, "User account is scheduled for deletion"}
        end

      _ ->
        {:error, :unauthenticated, "Invalid, expired, or revoked API token"}
    end
  end

  def check_email_verification_gate(%Faciqor.Accounts.User{email_confirmed_at: nil}) do
    {:error, :permission_denied, "Email verification required for API and CLI access"}
  end

  def check_email_verification_gate(%Faciqor.Accounts.User{}) do
    :ok
  end
end
