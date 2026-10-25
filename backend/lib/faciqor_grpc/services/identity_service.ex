defmodule FaciqorGrpc.Services.IdentityService do
  use GRPC.Server, service: Faciqor.V1.IdentityService.Service
  require Ash.Query

  alias Faciqor.Accounts
  alias Faciqor.V1

  def get_my_profile(_req, _stream) do
    actor = current_actor!()
    to_user_profile_response(actor)
  end

  def update_my_profile(%V1.UpdateMyProfileRequest{} = req, _stream) do
    actor = current_actor!()

    attrs =
      %{}
      |> maybe_put(:handle, req.handle)
      |> maybe_put(:display_name, req.display_name)
      |> maybe_put(:first_name, req.first_name)
      |> maybe_put(:last_name, req.last_name)
      |> maybe_put(:phone, req.phone)
      |> maybe_put(:timezone, req.timezone)
      |> maybe_put(:locale, req.locale)

    actor
    |> Ash.Changeset.for_update(:update_profile, attrs)
    |> Ash.update(actor: actor)
    |> case do
      {:ok, updated_user} -> to_user_profile_response(updated_user)
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def change_password(%V1.ChangePasswordRequest{current_password: current, new_password: new_pass}, _stream) do
    actor = current_actor!()

    actor
    |> Ash.Changeset.for_update(:change_password, %{
      current_password: current,
      password: new_pass,
      password_confirmation: new_pass
    })
    |> Ash.update(actor: actor)
    |> case do
      {:ok, _} -> %V1.ChangePasswordResponse{success: true}
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def request_email_change(%V1.RequestEmailChangeRequest{new_email: new_email}, _stream) do
    actor = current_actor!()

    actor
    |> Ash.Changeset.for_update(:request_email_change, %{new_email: new_email})
    |> Ash.update(actor: actor)
    |> case do
      {:ok, updated_user} ->
        %V1.RequestEmailChangeResponse{pending_email: to_string(updated_user.pending_email)}

      {:error, err} ->
        raise_ash_error!(err)
    end
  end

  def list_api_tokens(_req, _stream) do
    actor = current_actor!()

    tokens =
      Accounts.ApiToken
      |> Ash.Query.filter(user_id == ^actor.id)
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!(actor: actor)

    %V1.ListApiTokensResponse{
      tokens: Enum.map(tokens, &to_api_token_info/1)
    }
  end

  def create_api_token(%V1.CreateApiTokenRequest{} = req, _stream) do
    actor = current_actor!()

    opts = [actor: actor]
    opts = if req.expires_in_days && req.expires_in_days > 0, do: Keyword.put(opts, :expires_in_days, req.expires_in_days), else: opts
    opts = if req.scopes && req.scopes != "", do: Keyword.put(opts, :scopes, req.scopes), else: opts

    case Accounts.create_personal_access_token(req.name, opts) do
      {:ok, plain_token, record} ->
        %V1.CreateApiTokenResponse{
          token: to_api_token_info(record),
          plain_token: plain_token
        }

      {:error, err} ->
        raise_ash_error!(err)
    end
  end

  def revoke_api_token(%V1.RevokeApiTokenRequest{token_id: token_id}, _stream) do
    actor = current_actor!()

    case Accounts.ApiToken
         |> Ash.Query.filter(id == ^token_id and user_id == ^actor.id)
         |> Ash.read_one(actor: actor) do
      {:ok, %Accounts.ApiToken{} = token} ->
        token |> Ash.Changeset.for_update(:revoke, %{}) |> Ash.update!(actor: actor)
        %V1.RevokeApiTokenResponse{success: true}

      _ ->
        raise GRPC.RPCError, status: GRPC.Status.not_found(), message: "API Token nicht gefunden"
    end
  end

  def request_account_deletion(_req, _stream) do
    actor = current_actor!()
    orphaned_orgs = Accounts.list_orphaned_organizations_for_user(actor.id)
    orphaned_handles = Enum.map(orphaned_orgs, &to_string(&1.handle))

    actor
    |> Ash.Changeset.for_update(:soft_delete_user, %{})
    |> Ash.update(actor: actor)
    |> case do
      {:ok, deleted_user} ->
        purge_at = DateTime.add(deleted_user.deleted_at, 60 * 86400, :second)

        %V1.RequestAccountDeletionResponse{
          purge_scheduled_at: DateTime.to_iso8601(purge_at),
          orphaned_organization_handles: orphaned_handles
        }

      {:error, err} ->
        raise_ash_error!(err)
    end
  end

  def create_organization(%V1.CreateOrganizationRequest{} = req, _stream) do
    actor = current_actor!()

    attrs = %{
      handle: req.handle,
      primary_focus: from_proto_focus!(req.primary_focus),
      display_name: req.display_name,
      legal_name: req.legal_name,
      legal_form: req.legal_form,
      street_address: req.street_address,
      postal_code: req.postal_code,
      city: req.city,
      country_code: req.country_code || "DE",
      tax_id: req.tax_id,
      vat_id: req.vat_id,
      contact_email: req.contact_email
    }

    Accounts.create_organization(attrs, actor: actor)
    |> case do
      {:ok, org} ->
        org = Ash.load!(org, :memberships, actor: actor)
        to_organization_response(org, actor.id)

      {:error, err} ->
        raise_ash_error!(err)
    end
  end

  def list_my_organizations(_req, _stream) do
    actor = current_actor!()

    orgs =
      Accounts.Organization
      |> Ash.Query.filter(is_nil(deleted_at))
      |> Ash.Query.load(:memberships)
      |> Ash.read!(actor: actor)

    %V1.ListMyOrganizationsResponse{
      organizations: Enum.map(orgs, &to_organization_response(&1, actor.id))
    }
  end

  def get_organization(%V1.GetOrganizationRequest{id_or_handle: id_or_handle}, _stream) do
    actor = current_actor!()

    case Accounts.get_organization_by_id_or_handle(id_or_handle, actor: actor) do
      {:ok, org} -> to_organization_response(org, actor.id)
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def update_organization(%V1.UpdateOrganizationRequest{id_or_handle: id_or_handle} = req, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(id_or_handle, actor: actor) do
      attrs =
        %{}
        |> maybe_put(:handle, req.handle)
        |> maybe_put_focus(:primary_focus, req.primary_focus)
        |> maybe_put(:display_name, req.display_name)
        |> maybe_put(:legal_name, req.legal_name)
        |> maybe_put(:legal_form, req.legal_form)
        |> maybe_put(:street_address, req.street_address)
        |> maybe_put(:postal_code, req.postal_code)
        |> maybe_put(:city, req.city)
        |> maybe_put(:country_code, req.country_code)
        |> maybe_put(:tax_id, req.tax_id)
        |> maybe_put(:vat_id, req.vat_id)
        |> maybe_put(:contact_email, req.contact_email)

      org
      |> Ash.Changeset.for_update(:update_organization, attrs)
      |> Ash.update(actor: actor)
      |> case do
        {:ok, updated_org} ->
          updated_org = Ash.load!(updated_org, :memberships, actor: actor)
          to_organization_response(updated_org, actor.id)

        {:error, err} ->
          raise_ash_error!(err)
      end
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def soft_delete_organization(%V1.SoftDeleteOrganizationRequest{id_or_handle: id_or_handle}, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(id_or_handle, actor: actor) do
      org
      |> Ash.Changeset.for_update(:soft_delete, %{reason: :manual_by_owner})
      |> Ash.update(actor: actor)
      |> case do
        {:ok, deleted_org} ->
          deleted_org = Ash.load!(deleted_org, :memberships, actor: actor)
          to_organization_response(deleted_org, actor.id)

        {:error, err} ->
          raise_ash_error!(err)
      end
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  # --- Avatar & Logo Upload RPCs ---

  def get_avatar_upload_ticket(%V1.GetAvatarUploadTicketRequest{} = req, _stream) do
    actor = current_actor!()
    validate_upload_request!(req.byte_size, req.content_type)

    ext = extension_for_mime(req.content_type)
    key = "avatars/#{actor.id}/#{Ecto.UUID.generate()}.#{ext}"
    bucket = Faciqor.Media.Storage.public_bucket()

    {:ok, blob} =
      Faciqor.Media.create_storage_blob(
        %{
          bucket: bucket,
          key: key,
          sha256: req.sha256,
          content_type: req.content_type,
          byte_size: req.byte_size,
          context: :avatar,
          user_id: actor.id
        },
        actor: actor
      )

    {:ok, upload_url} = Faciqor.Media.Storage.generate_presigned_put_url(bucket, key)

    %V1.UploadTicketResponse{
      blob_id: blob.id,
      upload_url: upload_url,
      storage_key: key,
      headers: %{}
    }
  end

  def set_avatar(%V1.SetAvatarRequest{blob_id: blob_id}, _stream) do
    actor = current_actor!()

    case Accounts.set_user_avatar(actor, blob_id, actor: actor) do
      {:ok, updated_user} ->
        # Asynchronously process variants via Oban
        Faciqor.Media.Workers.ProcessImageVariants.new(%{"blob_id" => blob_id})
        |> Oban.insert()

        to_user_profile_response(updated_user)

      {:error, err} ->
        raise_ash_error!(err)
    end
  end

  def remove_avatar(%V1.RemoveAvatarRequest{}, _stream) do
    actor = current_actor!()

    case Accounts.remove_user_avatar(actor, actor: actor) do
      {:ok, updated_user} ->
        to_user_profile_response(updated_user)

      {:error, err} ->
        raise_ash_error!(err)
    end
  end

  def get_organization_logo_upload_ticket(%V1.GetOrganizationLogoUploadTicketRequest{} = req, _stream) do
    actor = current_actor!()
    validate_upload_request!(req.byte_size, req.content_type)

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(req.id_or_handle, actor: actor) do
      # Enforce owner permission
      verify_org_owner!(org, actor.id)

      ext = extension_for_mime(req.content_type)
      key = "logos/#{org.id}/#{Ecto.UUID.generate()}.#{ext}"
      bucket = Faciqor.Media.Storage.public_bucket()

      {:ok, blob} =
        Faciqor.Media.create_storage_blob(
          %{
            bucket: bucket,
            key: key,
            sha256: req.sha256,
            content_type: req.content_type,
            byte_size: req.byte_size,
            context: :organization_logo,
            organization_id: org.id
          },
          actor: actor
        )

      {:ok, upload_url} = Faciqor.Media.Storage.generate_presigned_put_url(bucket, key)

      %V1.UploadTicketResponse{
        blob_id: blob.id,
        upload_url: upload_url,
        storage_key: key,
        headers: %{}
      }
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def set_organization_logo(%V1.SetOrganizationLogoRequest{id_or_handle: id_or_handle, blob_id: blob_id}, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(id_or_handle, actor: actor) do
      verify_org_owner!(org, actor.id)

      case Accounts.set_organization_logo(org, blob_id, actor: actor) do
        {:ok, updated_org} ->
          Faciqor.Media.Workers.ProcessImageVariants.new(%{"blob_id" => blob_id})
          |> Oban.insert()

          updated_org = Ash.load!(updated_org, :memberships, actor: actor)
          to_organization_response(updated_org, actor.id)

        {:error, err} ->
          raise_ash_error!(err)
      end
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  def remove_organization_logo(%V1.RemoveOrganizationLogoRequest{id_or_handle: id_or_handle}, _stream) do
    actor = current_actor!()

    with {:ok, org} <- Accounts.get_organization_by_id_or_handle(id_or_handle, actor: actor) do
      verify_org_owner!(org, actor.id)

      case Accounts.remove_organization_logo(org, actor: actor) do
        {:ok, updated_org} ->
          updated_org = Ash.load!(updated_org, :memberships, actor: actor)
          to_organization_response(updated_org, actor.id)

        {:error, err} ->
          raise_ash_error!(err)
      end
    else
      {:error, err} -> raise_ash_error!(err)
    end
  end

  # --- Helpers & Mappers ---

  defp current_actor! do
    case Process.get(:faciqor_current_actor) do
      %Accounts.User{} = user -> user
      _ -> raise GRPC.RPCError, status: GRPC.Status.unauthenticated(), message: "Unauthenticated"
    end
  end

  defp to_user_profile_response(%Accounts.User{} = user) do
    {avatar_url, avatar_variants} = resolve_media_urls(user.avatar_blob_id)

    %V1.UserProfileResponse{
      id: user.id,
      email: to_string(user.email),
      handle: to_string(user.handle),
      email_verified: not is_nil(user.email_confirmed_at),
      inserted_at: if(user.inserted_at, do: DateTime.to_iso8601(user.inserted_at), else: ""),
      display_name: user.display_name || "",
      first_name: user.first_name || "",
      last_name: user.last_name || "",
      phone: user.phone || "",
      timezone: user.timezone || "Europe/Berlin",
      locale: user.locale || "de",
      pending_email: if(user.pending_email, do: to_string(user.pending_email), else: nil),
      avatar_url: avatar_url,
      avatar_variants: avatar_variants
    }
  end

  defp to_api_token_info(%Accounts.ApiToken{} = t) do
    %V1.ApiTokenInfo{
      id: t.id,
      name: t.name,
      token_prefix: t.token_prefix || "",
      scopes: t.scopes || "all",
      inserted_at: if(t.inserted_at, do: DateTime.to_iso8601(t.inserted_at), else: ""),
      expires_at: if(t.expires_at, do: DateTime.to_iso8601(t.expires_at), else: nil),
      last_used_at: if(t.last_used_at, do: DateTime.to_iso8601(t.last_used_at), else: nil),
      revoked_at: if(t.revoked_at, do: DateTime.to_iso8601(t.revoked_at), else: nil)
    }
  end

  defp to_organization_response(%Accounts.Organization{} = org, actor_id) do
    my_role =
      case Enum.find(org.memberships || [], &(&1.user_id == actor_id)) do
        %{role: :owner} -> :MEMBERSHIP_ROLE_OWNER
        %{role: :member} -> :MEMBERSHIP_ROLE_MEMBER
        %{role: :guest} -> :MEMBERSHIP_ROLE_GUEST
        _ -> :MEMBERSHIP_ROLE_UNSPECIFIED
      end

    {logo_url, logo_variants} = resolve_media_urls(org.logo_blob_id)

    %V1.OrganizationResponse{
      id: org.id,
      handle: to_string(org.handle),
      primary_focus: to_proto_focus(org.primary_focus),
      my_role: my_role,
      display_name: org.display_name || "",
      legal_name: org.legal_name || "",
      legal_form: org.legal_form || "",
      street_address: org.street_address || "",
      postal_code: org.postal_code || "",
      city: org.city || "",
      country_code: org.country_code || "DE",
      tax_id: org.tax_id || "",
      vat_id: org.vat_id || "",
      contact_email: if(org.contact_email, do: to_string(org.contact_email), else: ""),
      deleted_at: if(org.deleted_at, do: DateTime.to_iso8601(org.deleted_at), else: nil),
      logo_url: logo_url,
      logo_variants: logo_variants
    }
  end

  defp resolve_media_urls(blob_id) when is_binary(blob_id) do
    case Faciqor.Media.get_storage_blob(blob_id, authorize?: false) do
      {:ok, blob} ->
        standard_url =
          case blob.variants["512"] do
            key when is_binary(key) -> Faciqor.Media.Storage.public_url(key)
            _ -> Faciqor.Media.Storage.public_url(blob.key)
          end

        variants = %V1.MediaVariants{
          size_64: if(key = blob.variants["64"], do: Faciqor.Media.Storage.public_url(key), else: nil),
          size_128: if(key = blob.variants["128"], do: Faciqor.Media.Storage.public_url(key), else: nil),
          size_256: if(key = blob.variants["256"], do: Faciqor.Media.Storage.public_url(key), else: nil),
          size_512: if(key = blob.variants["512"], do: Faciqor.Media.Storage.public_url(key), else: nil)
        }

        {standard_url, variants}

      _ ->
        {nil, nil}
    end
  end

  defp resolve_media_urls(_), do: {nil, nil}

  defp validate_upload_request!(byte_size, content_type) do
    if byte_size && byte_size > 5 * 1024 * 1024 do
      raise GRPC.RPCError,
        status: GRPC.Status.invalid_argument(),
        message: "File size exceeds maximum allowed size of 5MB"
    end

    if content_type not in ["image/jpeg", "image/png", "image/webp"] do
      raise GRPC.RPCError,
        status: GRPC.Status.invalid_argument(),
        message: "Unsupported content type: #{content_type}. Allowed: image/jpeg, image/png, image/webp"
    end
  end

  defp verify_org_owner!(org, actor_id) do
    is_owner? =
      Enum.any?(org.memberships || [], fn m ->
        m.user_id == actor_id and m.role == :owner
      end)

    unless is_owner? do
      raise GRPC.RPCError,
        status: GRPC.Status.permission_denied(),
        message: "Only organization owners can modify the organization logo"
    end
  end

  defp extension_for_mime("image/jpeg"), do: "jpg"
  defp extension_for_mime("image/png"), do: "png"
  defp extension_for_mime("image/webp"), do: "webp"
  defp extension_for_mime(_), do: "bin"

  defp from_proto_focus!(:ORGANIZATION_FOCUS_PROPERTY_OWNER), do: :property_owner
  defp from_proto_focus!(:ORGANIZATION_FOCUS_PROPERTY_MANAGER), do: :property_manager
  defp from_proto_focus!(:ORGANIZATION_FOCUS_SERVICE_PROVIDER), do: :service_provider

  defp from_proto_focus!(_) do
    raise GRPC.RPCError,
      status: GRPC.Status.invalid_argument(),
      message: "primary_focus must be specified (property_owner, property_manager, or service_provider)"
  end

  defp to_proto_focus(:property_owner), do: :ORGANIZATION_FOCUS_PROPERTY_OWNER
  defp to_proto_focus(:property_manager), do: :ORGANIZATION_FOCUS_PROPERTY_MANAGER
  defp to_proto_focus(:service_provider), do: :ORGANIZATION_FOCUS_SERVICE_PROVIDER
  defp to_proto_focus(_), do: :ORGANIZATION_FOCUS_UNSPECIFIED

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, val), do: Map.put(map, key, val)

  defp maybe_put_focus(map, _key, nil), do: map
  defp maybe_put_focus(map, _key, :ORGANIZATION_FOCUS_UNSPECIFIED), do: map
  defp maybe_put_focus(map, key, focus), do: Map.put(map, key, from_proto_focus!(focus))

  @doc """
  Maps Ash domain errors to standard gRPC status codes according to section 5.2 of REQ-M1-BOILERPLATE.
  """
  def map_ash_error_to_grpc(%Ash.Error.Forbidden{} = err) do
    {GRPC.Status.permission_denied(), Exception.message(err)}
  end

  def map_ash_error_to_grpc(%Ash.Error.Query.NotFound{} = err) do
    {GRPC.Status.not_found(), Exception.message(err)}
  end

  def map_ash_error_to_grpc(%Ash.Error.Invalid{errors: errors} = err) do
    has_not_found? = Enum.any?(errors, &match?(%Ash.Error.Query.NotFound{}, &1))
    has_unique_conflict? =
      Enum.any?(errors, fn e ->
        msg = Exception.message(e)
        String.contains?(msg, "has already been taken") or String.contains?(msg, "already exists")
      end)

    cond do
      has_not_found? -> {GRPC.Status.not_found(), Exception.message(err)}
      has_unique_conflict? -> {GRPC.Status.already_exists(), Exception.message(err)}
      true -> {GRPC.Status.invalid_argument(), Exception.message(err)}
    end
  end

  def map_ash_error_to_grpc(err) do
    {GRPC.Status.internal(), Exception.message(err)}
  end

  defp raise_ash_error!(err) do
    {status, message} = map_ash_error_to_grpc(err)
    raise GRPC.RPCError, status: status, message: message
  end
end
