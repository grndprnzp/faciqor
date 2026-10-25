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

  @doc """
  Sets the avatar for a user.
  """
  def set_user_avatar(user, blob_id, opts \\ []) do
    actor = Keyword.get(opts, :actor, user)

    user
    |> Ash.Changeset.for_update(:set_avatar, %{blob_id: blob_id}, actor: actor)
    |> Ash.update(actor: actor)
  end

  @doc """
  Removes the avatar for a user.
  """
  def remove_user_avatar(user, opts \\ []) do
    actor = Keyword.get(opts, :actor, user)

    user
    |> Ash.Changeset.for_update(:remove_avatar, %{}, actor: actor)
    |> Ash.update(actor: actor)
  end

  @doc """
  Sets the logo for an organization.
  """
  def set_organization_logo(org, blob_id, opts \\ []) do
    actor = Keyword.fetch!(opts, :actor)

    org
    |> Ash.Changeset.for_update(:set_logo, %{blob_id: blob_id}, actor: actor)
    |> Ash.update(actor: actor)
  end

  @doc """
  Removes the logo for an organization.
  """
  def remove_organization_logo(org, opts \\ []) do
    actor = Keyword.fetch!(opts, :actor)

    org
    |> Ash.Changeset.for_update(:remove_logo, %{}, actor: actor)
    |> Ash.update(actor: actor)
  end

  @doc """
  Aktualisiert die Karten- und Geo-Such-Provider-Einstellungen einer Organisation
  (oder bei `apply_to_all_owned_orgs: true` transaktional für alle aktiven Organisationen,
  in denen `actor` die Rolle `:owner` besitzt).
  Gibt `{:ok, updated_org, updated_handles}` oder `{:error, error}` zurück.
  """
  def update_geo_provider_config(org, attrs, opts \\ []) when is_map(attrs) do
    actor = Keyword.fetch!(opts, :actor)
    apply_to_all? = Keyword.get(opts, :apply_to_all_owned_orgs, false)

    Faciqor.Repo.transaction(fn ->
      primary_updated =
        org
        |> Ash.Changeset.for_update(:update_geo_settings, attrs, actor: actor)
        |> Ash.update(actor: actor)
        |> case do
          {:ok, u} -> u
          {:error, err} -> Faciqor.Repo.rollback(err)
        end

      if apply_to_all? do
        effective_attrs = %{
          map_provider: primary_updated.map_provider,
          geocoding_provider: primary_updated.geocoding_provider,
          here_api_key: primary_updated.here_api_key
        }

        owned_orgs =
          Faciqor.Accounts.Organization
          |> Ash.Query.filter(
            is_nil(deleted_at) and memberships.user_id == ^actor.id and memberships.role == :owner
          )
          |> Ash.read!(actor: actor)

        handles =
          Enum.map(owned_orgs, fn target_org ->
            if target_org.id != primary_updated.id do
              target_org
              |> Ash.Changeset.for_update(:update_geo_settings, effective_attrs, actor: actor)
              |> Ash.update!(actor: actor)
            end

            to_string(target_org.handle)
          end)

        {primary_updated, handles}
      else
        {primary_updated, [to_string(primary_updated.handle)]}
      end
    end)
    |> case do
      {:ok, {updated_org, handles}} -> {:ok, updated_org, handles}
      {:error, err} -> {:error, err}
    end
  end
end
