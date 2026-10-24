defmodule FaciqorGrpc.Services.IdentityService do
  use GRPC.Server, service: Faciqor.V1.IdentityService.Service
  require Ash.Query

  alias Faciqor.Accounts
  alias Faciqor.V1

  def get_my_profile(_req, _stream) do
    actor = current_actor!()
    to_user_profile_response(actor)
  end

  def update_my_profile(%V1.UpdateMyProfileRequest{handle: handle}, _stream) do
    actor = current_actor!()

    actor
    |> Ash.Changeset.for_update(:update_profile, %{handle: handle})
    |> Ash.update(actor: actor)
    |> case do
      {:ok, updated_user} -> to_user_profile_response(updated_user)
      {:error, err} -> raise_ash_error!(err)
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

  # --- Helpers & Mappers ---

  defp current_actor! do
    case Process.get(:faciqor_current_actor) do
      %Accounts.User{} = user -> user
      _ -> raise GRPC.RPCError, status: GRPC.Status.unauthenticated(), message: "Unauthenticated"
    end
  end

  defp to_user_profile_response(%Accounts.User{} = user) do
    %V1.UserProfileResponse{
      id: user.id,
      email: to_string(user.email),
      handle: to_string(user.handle),
      email_verified: not is_nil(user.email_confirmed_at),
      inserted_at: if(user.inserted_at, do: DateTime.to_iso8601(user.inserted_at), else: "")
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
      deleted_at: if(org.deleted_at, do: DateTime.to_iso8601(org.deleted_at), else: nil)
    }
  end

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
