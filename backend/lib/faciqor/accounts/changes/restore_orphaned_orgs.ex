defmodule Faciqor.Accounts.Changes.RestoreOrphanedOrgs do
  use Ash.Resource.Change
  require Ash.Query

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, user ->
      memberships =
        Faciqor.Accounts.OrganizationMembership
        |> Ash.Query.filter(user_id == ^user.id and role == :owner)
        |> Ash.Query.load(:organization)
        |> Ash.read!(authorize?: false)

      Enum.each(memberships, fn membership ->
        if membership.organization.deletion_reason == :orphaned_by_last_owner do
          membership.organization
          |> Ash.Changeset.for_update(:restore_org, %{}, authorize?: false)
          |> Ash.update!()
        end
      end)

      {:ok, user}
    end)
  end
end
