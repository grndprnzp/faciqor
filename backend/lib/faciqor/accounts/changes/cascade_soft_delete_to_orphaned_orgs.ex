defmodule Faciqor.Accounts.Changes.CascadeSoftDeleteToOrphanedOrgs do
  use Ash.Resource.Change
  require Ash.Query

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, user ->
      # 1. Revoke all active ApiTokens for this user
      Faciqor.Accounts.ApiToken
      |> Ash.Query.filter(user_id == ^user.id and is_nil(revoked_at))
      |> Ash.read!(authorize?: false)
      |> Enum.each(fn token ->
        token
        |> Ash.Changeset.for_update(:revoke, %{}, authorize?: false)
        |> Ash.update!()
      end)

      # 2. Find all active organizations where the user is an owner
      memberships =
        Faciqor.Accounts.OrganizationMembership
        |> Ash.Query.filter(user_id == ^user.id and role == :owner)
        |> Ash.Query.load(:organization)
        |> Ash.read!(authorize?: false)

      Enum.each(memberships, fn membership ->
        if is_nil(membership.organization.deleted_at) do
          org_id = membership.organization_id

          other_owners_count =
            Faciqor.Accounts.OrganizationMembership
            |> Ash.Query.filter(
              organization_id == ^org_id and role == :owner and user_id != ^user.id and
                is_nil(user.deleted_at)
            )
            |> Ash.count!(authorize?: false)

          if other_owners_count == 0 do
            membership.organization
            |> Ash.Changeset.for_update(:soft_delete, %{reason: :orphaned_by_last_owner}, authorize?: false)
            |> Ash.update!()
          end
        end
      end)

      {:ok, user}
    end)
  end
end
