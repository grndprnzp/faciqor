defmodule Faciqor.Accounts do
  use Ash.Domain,
    otp_app: :faciqor

  require Ash.Query

  resources do
    resource Faciqor.Accounts.User
    resource Faciqor.Accounts.Token
    resource Faciqor.Accounts.UserIdentity
    resource Faciqor.Accounts.ApiToken
    resource Faciqor.Accounts.Organization
    resource Faciqor.Accounts.OrganizationMembership
  end

  @doc """
  Creates a new organization with the given actor as owner.
  """
  def create_organization(attrs, opts \\ []) do
    actor = Keyword.fetch!(opts, :actor)

    Faciqor.Accounts.Organization
    |> Ash.Changeset.for_create(:create_organization, attrs, actor: actor)
    |> Ash.create(actor: actor)
  end

  @doc """
  Generates a new Personal Access Token (`fq_pat_...`) for the given user (`actor`).
  Returns `{:ok, plain_token, api_token_record}` or `{:error, error}`.
  """
  def create_personal_access_token(name, opts \\ []) do
    actor = Keyword.fetch!(opts, :actor)
    scopes = Keyword.get(opts, :scopes, "all")

    expires_at =
      cond do
        Keyword.has_key?(opts, :expires_at) ->
          Keyword.get(opts, :expires_at)

        Keyword.has_key?(opts, :expires_in_days) ->
          case Keyword.get(opts, :expires_in_days) do
            days when is_integer(days) and days > 0 ->
              DateTime.add(DateTime.utc_now(), days * 86400, :second)

            _ ->
              nil
          end

        true ->
          DateTime.add(DateTime.utc_now(), 365 * 86400, :second)
      end

    plain_token = "fq_pat_" <> (:crypto.strong_rand_bytes(24) |> Base.url_encode64(padding: false))

    Faciqor.Accounts.ApiToken
    |> Ash.Changeset.for_create(:generate, %{
      name: name,
      expires_at: expires_at,
      scopes: scopes,
      token_plain: plain_token
    }, actor: actor)
    |> Ash.create(actor: actor)
    |> case do
      {:ok, record} -> {:ok, plain_token, record}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Finds all active organizations where the given user is the sole remaining active `:owner`.
  """
  def list_orphaned_organizations_for_user(user_id) do
    memberships =
      Faciqor.Accounts.OrganizationMembership
      |> Ash.Query.filter(user_id == ^user_id and role == :owner)
      |> Ash.Query.load(:organization)
      |> Ash.read!(authorize?: false)

    memberships
    |> Enum.filter(fn m ->
      is_nil(m.organization.deleted_at) and
        other_active_owners_count(m.organization_id, user_id) == 0
    end)
    |> Enum.map(& &1.organization)
  end

  defp other_active_owners_count(org_id, user_id) do
    Faciqor.Accounts.OrganizationMembership
    |> Ash.Query.filter(
      organization_id == ^org_id and role == :owner and user_id != ^user_id and
        is_nil(user.deleted_at)
    )
    |> Ash.count!(authorize?: false)
  end

  @doc """
  Looks up an organization by UUID or handle for the given actor.
  """
  def get_organization_by_id_or_handle(id_or_handle, opts \\ []) do
    actor = Keyword.fetch!(opts, :actor)

    query =
      if valid_uuid?(id_or_handle) do
        Faciqor.Accounts.Organization
        |> Ash.Query.filter(id == ^id_or_handle and is_nil(deleted_at))
      else
        Faciqor.Accounts.Organization
        |> Ash.Query.filter(handle == ^id_or_handle and is_nil(deleted_at))
      end

    case query |> Ash.Query.load(:memberships) |> Ash.read_one(actor: actor) do
      {:ok, nil} -> {:error, Ash.Error.Query.NotFound.exception(primary_key: %{id_or_handle: id_or_handle}, resource: Faciqor.Accounts.Organization)}
      {:ok, org} -> {:ok, org}
      {:error, err} -> {:error, err}
    end
  end

  defp valid_uuid?(str) when is_binary(str) do
    case Ecto.UUID.cast(str) do
      {:ok, formatted} -> byte_size(str) == 36 and String.downcase(str) == String.downcase(formatted)
      _ -> false
    end
  end

  defp valid_uuid?(_), do: false
end
