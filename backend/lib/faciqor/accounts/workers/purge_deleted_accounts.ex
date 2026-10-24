defmodule Faciqor.Accounts.Workers.PurgeDeletedAccounts do
  use Oban.Worker, queue: :default, max_attempts: 3
  require Ash.Query

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    sixty_days_ago = DateTime.add(DateTime.utc_now(), -60 * 86400, :second)

    # 1. Purge organizations soft-deleted more than 60 days ago
    Faciqor.Accounts.Organization
    |> Ash.Query.filter(not is_nil(deleted_at) and deleted_at < ^sixty_days_ago)
    |> Ash.read!(authorize?: false)
    |> Enum.each(fn org ->
      Ash.destroy!(org, authorize?: false)
    end)

    # 2. Purge users soft-deleted more than 60 days ago
    Faciqor.Accounts.User
    |> Ash.Query.filter(not is_nil(deleted_at) and deleted_at < ^sixty_days_ago)
    |> Ash.read!(authorize?: false)
    |> Enum.each(fn user ->
      Ash.destroy!(user, authorize?: false)
    end)

    :ok
  end
end
