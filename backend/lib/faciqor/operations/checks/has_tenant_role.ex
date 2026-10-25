defmodule Faciqor.Operations.Checks.HasTenantRole do
  @moduledoc """
  Ash Policy SimpleCheck zur Verifikation der Mandanten-Mitgliedschaft und Rolle
  (`:owner`, `:member`, `:guest`) des aktuellen `actor` im gesetzten `tenant`-Kontext.
  """
  use Ash.Policy.SimpleCheck
  require Ash.Query

  alias Faciqor.Accounts.OrganizationMembership

  @impl true
  def describe(opts) do
    roles = Keyword.get(opts, :roles, [:owner, :member, :guest])
    "actor has one of roles #{inspect(roles)} in current tenant organization"
  end

  @impl true
  def match?(nil, _context, _opts), do: false

  def match?(%{id: user_id}, context, opts) when is_binary(user_id) do
    allowed_roles = Keyword.get(opts, :roles, [:owner, :member, :guest])
    tenant_id = extract_tenant_id(context)

    if is_binary(tenant_id) and tenant_id != "" do
      OrganizationMembership
      |> Ash.Query.filter(
        user_id == ^user_id and organization_id == ^tenant_id and role in ^allowed_roles
      )
      |> Ash.exists?(authorize?: false)
    else
      false
    end
  end

  def match?(_actor, _context, _opts), do: false

  defp extract_tenant_id(%{tenant: tenant}) when is_binary(tenant), do: tenant
  defp extract_tenant_id(%{changeset: %{tenant: tenant}}) when is_binary(tenant), do: tenant
  defp extract_tenant_id(%{query: %{tenant: tenant}}) when is_binary(tenant), do: tenant
  defp extract_tenant_id(_), do: nil
end
