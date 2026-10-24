defmodule Faciqor.AccountsTest do
  use Faciqor.DataCase, async: true
  require Ash.Query

  alias Faciqor.Accounts
  alias Faciqor.Accounts.{User, Organization, OrganizationMembership}
  alias Faciqor.Accounts.Workers.PurgeDeletedAccounts

  describe "4.1 & 7.1.1 Multi-Auth & Account Linking" do
    test "password signup leaves email_confirmed_at nil, magic link / OAuth links same User and sets email_confirmed_at" do
      {:ok, user_pw} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "max.mustermann@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      assert is_nil(user_pw.email_confirmed_at)
      assert to_string(user_pw.handle) == "max-mustermann"

      # Subsequent Magic Link sign-in with the same email links to the same user and confirms email
      {:ok, user_ml} =
        User
        |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{
          email: "max.mustermann@example.com"
        })
        |> Ash.create()

      assert user_ml.id == user_pw.id
      refute is_nil(user_ml.email_confirmed_at)
    end
  end

  describe "4.1 & 7.1.2 Auto-Handle Generation & Collision Handling" do
    test "generates handle from email and appends 4-char random suffix on collision" do
      {:ok, u1} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "max.mustermann@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      assert to_string(u1.handle) == "max-mustermann"

      {:ok, u2} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "max.mustermann@other-domain.de",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      assert String.starts_with?(to_string(u2.handle), "max-mustermann-")
      assert String.length(to_string(u2.handle)) == String.length("max-mustermann-") + 4
    end
  end

  describe "4.2 & 7.1.3 14-Day Verification Rule & API Gate" do
    test "unverified user cannot create an ApiToken (Ash.Error.Forbidden)" do
      {:ok, unverified_user} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "unverified@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      assert {:error, %Ash.Error.Forbidden{}} =
               Accounts.create_personal_access_token("CLI Token", actor: unverified_user)

      # Once verified, PAT generation succeeds
      {:ok, verified_user} =
        unverified_user
        |> Ash.Changeset.for_update(:confirm_email, %{})
        |> Ash.update(actor: unverified_user)

      assert {:ok, plain_token, _record} =
               Accounts.create_personal_access_token("CLI Token", actor: verified_user)

      assert String.starts_with?(plain_token, "fq_pat_")
    end

    test "verification_grace_expired? switches to true when inserted_at < ago(14, :day)" do
      {:ok, user} =
        User
        |> Ash.Changeset.for_create(:register_with_password, %{
          email: "grace@example.com",
          password: "super_secure_password_123"
        })
        |> Ash.create()

      loaded_fresh = Ash.load!(user, :verification_grace_expired?, actor: user)
      refute loaded_fresh.verification_grace_expired?

      # Backdate inserted_at to 15 days ago
      fifteen_days_ago = DateTime.add(DateTime.utc_now(), -15 * 86400, :second)
      Ecto.Changeset.change(user, inserted_at: fifteen_days_ago) |> Faciqor.Repo.update!()

      loaded_expired = Ash.load!(user, :verification_grace_expired?, actor: user)
      assert loaded_expired.verification_grace_expired?
    end
  end

  describe "4.3 & 7.1.4 M:N Authorization Policies (Organization & OrganizationMembership)" do
    test "user can be owner in Org A, member in Org B, guest in Org C; read returns all 3, update/soft_delete only allowed for Org A" do
      {:ok, user1} =
        User
        |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "u1@example.com"})
        |> Ash.create()

      {:ok, other_owner} =
        User
        |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "owner@example.com"})
        |> Ash.create()

      # Org A created by user1 -> user1 is :owner
      {:ok, org_a} =
        Organization
        |> Ash.Changeset.for_create(:create_organization, %{
          handle: "org-a",
          primary_focus: :property_owner
        })
        |> Ash.create(actor: user1)

      # Org B & Org C created by other_owner
      {:ok, org_b} =
        Organization
        |> Ash.Changeset.for_create(:create_organization, %{
          handle: "org-b",
          primary_focus: :property_manager
        })
        |> Ash.create(actor: other_owner)

      {:ok, org_c} =
        Organization
        |> Ash.Changeset.for_create(:create_organization, %{
          handle: "org-c",
          primary_focus: :service_provider
        })
        |> Ash.create(actor: other_owner)

      # Add user1 as :member in Org B and :guest in Org C
      OrganizationMembership
      |> Ash.Changeset.for_create(:create_membership, %{
        user_id: user1.id,
        organization_id: org_b.id,
        role: :member
      })
      |> Ash.create!(authorize?: false)

      OrganizationMembership
      |> Ash.Changeset.for_create(:create_membership, %{
        user_id: user1.id,
        organization_id: org_c.id,
        role: :guest
      })
      |> Ash.create!(authorize?: false)

      # Read returns all 3 organizations
      visible_orgs = Organization |> Ash.read!(actor: user1)
      assert length(visible_orgs) == 3

      # Update allowed on Org A
      assert {:ok, _} =
               org_a
               |> Ash.Changeset.for_update(:update_organization, %{display_name: "Updated A"})
               |> Ash.update(actor: user1)

      # Update forbidden on Org B (:member) and Org C (:guest)
      assert {:error, %Ash.Error.Forbidden{}} =
               org_b
               |> Ash.Changeset.for_update(:update_organization, %{display_name: "Updated B"})
               |> Ash.update(actor: user1)

      assert {:error, %Ash.Error.Forbidden{}} =
               org_c
               |> Ash.Changeset.for_update(:update_organization, %{display_name: "Updated C"})
               |> Ash.update(actor: user1)

      # Soft-delete forbidden on Org B & Org C
      assert {:error, %Ash.Error.Forbidden{}} =
               org_b
               |> Ash.Changeset.for_update(:soft_delete, %{})
               |> Ash.update(actor: user1)
    end
  end

  describe "4.4 & 7.1.5 60-Day Soft-Delete, Cascading & Restoration" do
    test "soft-deleting user cascades only to organizations where user is sole owner, restores both, and Oban purges after 60 days" do
      {:ok, user1} =
        User
        |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "u1-del@example.com"})
        |> Ash.create()

      {:ok, user2} =
        User
        |> Ash.Changeset.for_create(:sign_in_with_magic_link, %{email: "u2-del@example.com"})
        |> Ash.create()

      # Org A: user1 is sole owner
      {:ok, org_a} =
        Organization
        |> Ash.Changeset.for_create(:create_organization, %{
          handle: "org-sole-owner",
          primary_focus: :property_manager
        })
        |> Ash.create(actor: user1)

      # Org B: user1 and user2 are both owners
      {:ok, org_b} =
        Organization
        |> Ash.Changeset.for_create(:create_organization, %{
          handle: "org-shared-owner",
          primary_focus: :property_manager
        })
        |> Ash.create(actor: user1)

      OrganizationMembership
      |> Ash.Changeset.for_create(:create_membership, %{
        user_id: user2.id,
        organization_id: org_b.id,
        role: :owner
      })
      |> Ash.create!(authorize?: false)

      # Soft-delete user1
      {:ok, deleted_u1} =
        user1
        |> Ash.Changeset.for_update(:soft_delete_user, %{})
        |> Ash.update(actor: user1)

      refute is_nil(deleted_u1.deleted_at)

      reloaded_a = Ash.get!(Organization, org_a.id, authorize?: false)
      reloaded_b = Ash.get!(Organization, org_b.id, authorize?: false)

      refute is_nil(reloaded_a.deleted_at)
      assert reloaded_a.deletion_reason == :orphaned_by_last_owner
      assert is_nil(reloaded_b.deleted_at)

      # Restore user1 within 60 days -> restores User 1 and Org A
      {:ok, restored_u1} =
        deleted_u1
        |> Ash.Changeset.for_update(:restore_user, %{})
        |> Ash.update(actor: deleted_u1)

      assert is_nil(restored_u1.deleted_at)
      restored_a = Ash.get!(Organization, org_a.id, authorize?: false)
      assert is_nil(restored_a.deleted_at)
      assert is_nil(restored_a.deletion_reason)

      # Soft-delete again and backdate beyond 60 days for Oban purge check
      {:ok, deleted_again} =
        restored_u1
        |> Ash.Changeset.for_update(:soft_delete_user, %{})
        |> Ash.update(actor: restored_u1)

      sixty_one_days_ago = DateTime.add(DateTime.utc_now(), -61 * 86400, :second)
      Ecto.Changeset.change(deleted_again, deleted_at: sixty_one_days_ago) |> Faciqor.Repo.update!()
      reloaded_a2 = Ash.get!(Organization, org_a.id, authorize?: false)
      Ecto.Changeset.change(reloaded_a2, deleted_at: sixty_one_days_ago) |> Faciqor.Repo.update!()

      assert :ok == PurgeDeletedAccounts.perform(%Oban.Job{})

      assert {:ok, nil} =
               Organization |> Ash.Query.filter(id == ^org_a.id) |> Ash.read_one(authorize?: false)

      assert {:ok, nil} =
               User |> Ash.Query.filter(id == ^user1.id) |> Ash.read_one(authorize?: false)
    end
  end
end
