defmodule Faciqor.Accounts.Changes.GenerateDefaultHandle do
  use Ash.Resource.Change
  require Ash.Query

  @impl true
  def change(changeset, _opts, _context) do
    case Ash.Changeset.get_attribute(changeset, :handle) do
      nil ->
        email = Ash.Changeset.get_attribute(changeset, :email)
        base = derive_handle_from_email(to_string(email))
        handle = ensure_unique_handle(base, changeset.resource)
        Ash.Changeset.change_attribute(changeset, :handle, handle)

      _ ->
        changeset
    end
  end

  defp derive_handle_from_email(email) do
    prefix =
      email
      |> String.split("@")
      |> List.first()
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9_-]/, "-")
      |> String.trim("-")

    if String.length(prefix) < 3 do
      "user-" <> random_suffix()
    else
      String.slice(prefix, 0, 24)
    end
  end

  defp ensure_unique_handle(candidate, resource) do
    case resource |> Ash.Query.filter(handle == ^candidate) |> Ash.read_one(authorize?: false) do
      {:ok, nil} -> candidate
      _ -> "#{candidate}-#{random_suffix()}"
    end
  rescue
    _ -> "#{candidate}-#{random_suffix()}"
  end

  defp random_suffix do
    :crypto.strong_rand_bytes(2) |> Base.encode16(case: :lower)
  end
end
