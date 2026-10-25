defmodule FaciqorGrpc.IdentityServiceTest do
  use Faciqor.DataCase, async: true

  alias Faciqor.Accounts
  alias Faciqor.Accounts.User
  alias Faciqor.V1
  alias FaciqorGrpc.Interceptors.Auth
  alias FaciqorGrpc.Services.IdentityService

  describe "5.2 & 7.3.1 gRPC Interceptor & Unverified Gate" do
    test "rejects unverified user with PERMISSION_DENIED" do
      {:ok, unverified_user} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "grpc-unverified@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      assert {:error, :permission_denied, "Email verification required for API and CLI access"} =
               Auth.check_email_verification_gate(unverified_user)
    end

    test "authenticates valid PAT and executes IdentityService RPCs" do
      {:ok, user} =
        User
        |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "grpc-verified@example.com"})
        |> Ash.create()

      {:ok, plain_token, _record} = Accounts.create_personal_access_token("Test CLI", actor: user)

      assert {:ok, loaded_user} = Auth.verify_pat_and_load_user(plain_token)
      assert loaded_user.id == user.id
      assert :ok == Auth.check_email_verification_gate(loaded_user)

      Process.put(:faciqor_current_actor, loaded_user)

      profile_res = IdentityService.get_my_profile(%V1.GetMyProfileRequest{}, nil)
      assert profile_res.email == "grpc-verified@example.com"
      assert profile_res.email_verified == true

      org_res =
        IdentityService.create_organization(
          %V1.CreateOrganizationRequest{
            handle: "meine-hv",
            primary_focus: :ORGANIZATION_FOCUS_PROPERTY_MANAGER,
            legal_name: "Muster Hausverwaltung GmbH"
          },
          nil
        )

      assert org_res.handle == "meine-hv"
      assert org_res.my_role == :MEMBERSHIP_ROLE_OWNER

      # Profile update with display name, names, timezone, locale
      updated_profile =
        IdentityService.update_my_profile(
          %V1.UpdateMyProfileRequest{
            display_name: "Max Mustermann",
            first_name: "Max",
            last_name: "Mustermann",
            phone: "+49 170 1234567",
            timezone: "Europe/Berlin",
            locale: "de"
          },
          nil
        )

      assert updated_profile.display_name == "Max Mustermann"
      assert updated_profile.first_name == "Max"
      assert updated_profile.last_name == "Mustermann"
      assert updated_profile.phone == "+49 170 1234567"
      assert updated_profile.timezone == "Europe/Berlin"
      assert updated_profile.locale == "de"

      # Request email change
      email_res =
        IdentityService.request_email_change(
          %V1.RequestEmailChangeRequest{new_email: "max.neu@example.com"},
          nil
        )

      assert email_res.pending_email == "max.neu@example.com"

      # Create API token via gRPC
      token_res =
        IdentityService.create_api_token(
          %V1.CreateApiTokenRequest{name: "CLI Server", expires_in_days: 90, scopes: "all"},
          nil
        )

      assert token_res.token.name == "CLI Server"
      assert String.starts_with?(token_res.plain_token, "fq_pat_")
      assert token_res.token.token_prefix != ""

      # List API tokens via gRPC
      list_res = IdentityService.list_api_tokens(%V1.ListApiTokensRequest{}, nil)
      assert length(list_res.tokens) >= 2

      # Revoke API token via gRPC
      revoke_res =
        IdentityService.revoke_api_token(
          %V1.RevokeApiTokenRequest{token_id: token_res.token.id},
          nil
        )

      assert revoke_res.success == true

      # Avatar upload ticket
      avatar_ticket =
        IdentityService.get_avatar_upload_ticket(
          %V1.GetAvatarUploadTicketRequest{
            content_type: "image/png",
            byte_size: 1024,
            sha256: "dummy-sha256"
          },
          nil
        )

      assert avatar_ticket.blob_id != ""
      assert String.contains?(avatar_ticket.upload_url, "faciqor-public")
      assert String.contains?(avatar_ticket.storage_key, "avatars/#{user.id}/")

      # Set avatar
      avatar_profile =
        IdentityService.set_avatar(%V1.SetAvatarRequest{blob_id: avatar_ticket.blob_id}, nil)

      assert avatar_profile.avatar_url != ""

      # Remove avatar
      cleared_profile = IdentityService.remove_avatar(%V1.RemoveAvatarRequest{}, nil)
      assert is_nil(cleared_profile.avatar_url)

      # Organization logo ticket (as owner)
      logo_ticket =
        IdentityService.get_organization_logo_upload_ticket(
          %V1.GetOrganizationLogoUploadTicketRequest{
            id_or_handle: org_res.id,
            content_type: "image/png",
            byte_size: 2048,
            sha256: "dummy-sha256"
          },
          nil
        )

      assert logo_ticket.blob_id != ""
      assert String.contains?(logo_ticket.storage_key, "logos/#{org_res.id}/")

      # Set org logo
      logo_org =
        IdentityService.set_organization_logo(
          %V1.SetOrganizationLogoRequest{
            id_or_handle: org_res.id,
            blob_id: logo_ticket.blob_id
          },
          nil
        )

      assert logo_org.logo_url != ""

      # Remove org logo
      cleared_logo_org =
        IdentityService.remove_organization_logo(
          %V1.RemoveOrganizationLogoRequest{id_or_handle: org_res.id},
          nil
        )

      assert is_nil(cleared_logo_org.logo_url)
    end
  end
end
