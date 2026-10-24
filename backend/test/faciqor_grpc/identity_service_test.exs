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
    end
  end
end
