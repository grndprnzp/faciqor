defmodule Faciqor.Accounts.Changes.CreateOwnerMembership do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    Ash.Changeset.after_action(changeset, fn changeset, org ->
      actor =
        Map.get(context, :actor) ||
          Map.get(changeset.context, :actor) ||
          get_in(changeset.context, [:private, :actor])

      case actor do
        %{id: user_id} when not is_nil(user_id) ->
          Faciqor.Accounts.OrganizationMembership
          |> Ash.Changeset.for_create(
            :create_membership,
            %{
              user_id: user_id,
              organization_id: org.id,
              role: :owner
            },
            authorize?: false
          )
          |> Ash.create!(authorize?: false)

          Faciqor.Operations.ensure_default_number_range(org.id, :facility)

          {:ok, org}

        _ ->
          Faciqor.Operations.ensure_default_number_range(org.id, :facility)
          {:ok, org}
      end
    end)
  end
end
