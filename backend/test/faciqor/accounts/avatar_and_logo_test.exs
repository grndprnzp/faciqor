defmodule Faciqor.Accounts.AvatarAndLogoTest do
  use ExUnit.Case, async: false
  alias Faciqor.Accounts
  alias Faciqor.Accounts.User
  alias Faciqor.Accounts.Organization
  alias Faciqor.Accounts.OrganizationMembership
  alias Faciqor.Media

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Faciqor.Repo)

    # Create test user 1 (owner)
    {:ok, user1} =
      User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "avatar_user1@example.com",
        password: "Password1234!",
        handle: "avataruser1"
      })
      |> Ash.create()

    # Create test user 2 (regular member)
    {:ok, user2} =
      User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "avatar_user2@example.com",
        password: "Password1234!",
        handle: "avataruser2"
      })
      |> Ash.create()

    # Create organization owned by user 1
    {:ok, org} =
      Organization
      |> Ash.Changeset.for_create(
        :create_organization,
        %{
          handle: "logo-org-1",
          primary_focus: :property_owner,
          display_name: "Logo Test Org"
        },
        actor: user1
      )
      |> Ash.create(actor: user1)

    # Add user 2 as member
    {:ok, _membership} =
      OrganizationMembership
      |> Ash.Changeset.for_create(
        :create_membership,
        %{
          role: :member,
          user_id: user2.id,
          organization_id: org.id
        },
        actor: user1
      )
      |> Ash.create(actor: user1)

    # Create a test storage blob
    {:ok, blob1} =
      Media.create_storage_blob(
        %{
          bucket: "faciqor-public",
          key: "avatars/#{user1.id}/test1.png",
          content_type: "image/png",
          context: :avatar,
          user_id: user1.id
        },
        actor: user1
      )

    # Create a test storage blob for org logo
    {:ok, logo_blob} =
      Media.create_storage_blob(
        %{
          bucket: "faciqor-public",
          key: "logos/#{org.id}/logo1.png",
          content_type: "image/png",
          context: :organization_logo,
          organization_id: org.id
        },
        actor: user1
      )

    %{user1: user1, user2: user2, org: org, blob1: blob1, logo_blob: logo_blob}
  end

  describe "User Avatar" do
    test "user can set and remove their own avatar", %{user1: user1, blob1: blob1} do
      assert {:ok, updated} = Accounts.set_user_avatar(user1, blob1.id, actor: user1)
      assert updated.avatar_blob_id == blob1.id

      assert {:ok, cleared} = Accounts.remove_user_avatar(updated, actor: user1)
      assert is_nil(cleared.avatar_blob_id)
    end

    test "user cannot set avatar for another user", %{user1: user1, user2: user2, blob1: blob1} do
      assert {:error, _error} = Accounts.set_user_avatar(user1, blob1.id, actor: user2)
    end
  end

  describe "Organization Logo" do
    test "owner can set and remove organization logo", %{user1: user1, org: org, logo_blob: logo_blob} do
      assert {:ok, updated} = Accounts.set_organization_logo(org, logo_blob.id, actor: user1)
      assert updated.logo_blob_id == logo_blob.id

      assert {:ok, cleared} = Accounts.remove_organization_logo(updated, actor: user1)
      assert is_nil(cleared.logo_blob_id)
    end

    test "regular member cannot set or remove organization logo", %{user2: user2, org: org, logo_blob: logo_blob} do
      assert {:error, _error} = Accounts.set_organization_logo(org, logo_blob.id, actor: user2)
      assert {:error, _error} = Accounts.remove_organization_logo(org, actor: user2)
    end
  end
end
