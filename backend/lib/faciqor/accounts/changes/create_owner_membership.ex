defmodule Faciqor.Accounts.Changes.CreateOwnerMembership do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, %{actor: actor}) when not is_nil(actor) do
    Ash.Changeset.after_action(changeset, fn _changeset, org ->
      Faciqor.Accounts.OrganizationMembership
      |> Ash.Changeset.for_create(
        :create_membership,
        %{
          user_id: actor.id,
          organization_id: org.id,
          role: :owner
        },
        authorize?: false
      )
      |> Ash.create!()

      {:ok, org}
    end)
  end

  def change(changeset, _opts, _context), do: changeset
end
