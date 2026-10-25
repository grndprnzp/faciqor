defmodule FaciqorWeb.Layouts do
  use FaciqorWeb, :html

  attr :current_user, :any, default: nil
  attr :current_org, :any, default: nil
  attr :user_orgs, :list, default: []
  attr :inner_content, :any, required: true
  attr :flash, :map, default: %{}

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="de" class="h-full antialiased">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={get_csrf_token()} />
        <title>Faciqor Hub</title>
        <link rel="stylesheet" href={~p"/assets/css/app.css"} />
        <script defer phx-track-static type="text/javascript" src={~p"/assets/js/app.js"}>
        </script>
      </head>
      <body class="h-full bg-[var(--fq-color-bg-app)] text-[var(--fq-color-text-main)] text-sm">
        <%= @inner_content %>
      </body>
    </html>
    """
  end

  def app(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col bg-[var(--fq-color-bg-app)]">
      <%!-- Permanent 14-Day Verification Warning Banner --%>
      <div
        :if={@current_user && is_nil(@current_user.email_confirmed_at)}
        id="verification-warning-banner"
        class="bg-[#FFFBEB] border-b border-[#F59E0B] px-6 py-2.5 text-[#92400E] flex items-center justify-between text-xs lg:text-sm"
      >
        <div class="flex items-center gap-2">
          <span class="font-semibold">Unbestätigte E-Mail-Adresse:</span>
          <span>
            Bitte bestätigen Sie Ihre E-Mail-Adresse innerhalb der nächsten <%= remaining_grace_days(@current_user) %> Tage.
            Bis zur Bestätigung sind CLI-/API-Zugriffe und ausgehende E-Mails deaktiviert.
          </span>
        </div>
        <button
          type="button"
          phx-click="resend_verification_email"
          class="font-medium underline hover:opacity-80 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB] rounded px-2 py-0.5"
        >
          Bestätigungs-E-Mail erneut senden
        </button>
      </div>

      <%!-- Top App Shell Header with Multi-Tenant Switcher --%>
      <header :if={@current_user} class="bg-[var(--fq-color-bg-surface)] border-b border-[var(--fq-color-border)] px-6 h-14 flex items-center justify-between">
        <div class="flex items-center gap-6">
          <a href={~p"/dashboard"} class="font-bold text-base tracking-tight text-[var(--fq-color-primary)]">
            Faciqor Hub
          </a>

          <%!-- Multi-Tenant Organization Switcher --%>
          <div class="flex items-center gap-2" id="tenant-switcher">
            <span class="text-xs text-[var(--fq-color-text-muted)]">Mandant:</span>
            <%= if assigns[:current_org] do %>
              <div class="inline-flex items-center gap-2 px-3 py-1 rounded-md border border-[var(--fq-color-border)] bg-[var(--fq-color-bg-muted)]">
                <span class="fq-mono font-medium text-xs">@<%= assigns[:current_org].handle %></span>
                <.status_badge status={org_role(assigns[:current_org], @current_user)} />
              </div>
            <% else %>
              <span class="text-xs italic text-[var(--fq-color-text-muted)]">Keine Organisation gewählt</span>
            <% end %>
            <a
              href={~p"/orgs/new"}
              class="text-xs font-medium text-[var(--fq-color-primary)] hover:underline ml-2"
            >
              + Neue Organisation gründen
            </a>
          </div>
        </div>

        <nav class="flex items-center gap-3">
          <a
            href={~p"/settings/profile"}
            class="text-xs font-medium text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)] flex items-center gap-2 px-2 py-1 rounded-md hover:bg-[var(--fq-color-bg-muted)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]"
          >
            <span class="inline-flex items-center justify-center w-6 h-6 rounded-full bg-[var(--fq-color-bg-muted)] border border-[var(--fq-color-border)] text-[var(--fq-color-text-main)] font-semibold text-[10px]">
              <%= user_initials(@current_user) %>
            </span>
            <span class="font-medium text-[var(--fq-color-text-main)]"><%= user_display(@current_user) %></span>
            <span class="text-[var(--fq-color-text-muted)] text-[11px] hidden sm:inline">(Profil &amp; CLI)</span>
          </a>

          <span class="h-4 w-px bg-[var(--fq-color-border)]" aria-hidden="true"></span>

          <.link
            href={~p"/sign-out"}
            method="delete"
            id="header-sign-out-btn"
            class="text-xs font-medium text-[var(--fq-color-text-muted)] hover:text-[var(--fq-status-danger)] hover:bg-[#FEF2F2] px-2.5 py-1.5 rounded-md transition-colors flex items-center gap-1.5 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]"
            title="Vom System abmelden"
          >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
              <path fill-rule="evenodd" d="M3 4.25A2.25 2.25 0 015.25 2h5.5A2.25 2.25 0 0113 4.25v2a.75.75 0 01-1.5 0v-2a.75.75 0 00-.75-.75h-5.5a.75.75 0 00-.75.75v11.5c0 .414.336.75.75.75h5.5a.75.75 0 00.75-.75v-2a.75.75 0 011.5 0v2A2.25 2.25 0 0110.75 18h-5.5A2.25 2.25 0 013 15.75V4.25z" clip-rule="evenodd" />
              <path fill-rule="evenodd" d="M19 10a.75.75 0 00-.75-.75H8.704l2.47-2.47a.75.75 0 10-1.06-1.06l-3.75 3.75a.75.75 0 000 1.06l3.75 3.75a.75.75 0 101.06-1.06l-2.47-2.47H18.25A.75.75 0 0019 10z" clip-rule="evenodd" />
            </svg>
            <span>Abmelden</span>
          </.link>
        </nav>
      </header>

      <%!-- Flash Messages --%>
      <div :if={Phoenix.Flash.get(@flash, :info)} class="mx-6 mt-4 p-3 rounded-md bg-[#ECFDF5] text-[#065F46] text-xs font-medium">
        <%= Phoenix.Flash.get(@flash, :info) %>
      </div>
      <div :if={Phoenix.Flash.get(@flash, :error)} class="mx-6 mt-4 p-3 rounded-md bg-[#FEF2F2] text-[#991B1B] text-xs font-medium">
        <%= Phoenix.Flash.get(@flash, :error) %>
      </div>

      <main class="flex-1 mx-auto w-full max-w-6xl px-6 py-8">
        <%= @inner_content %>
      </main>
    </div>
    """
  end

  defp remaining_grace_days(%{inserted_at: nil}), do: 14

  defp remaining_grace_days(%{inserted_at: inserted_at}) do
    elapsed_days = div(DateTime.diff(DateTime.utc_now(), inserted_at, :second), 86400)
    max(0, 14 - elapsed_days)
  end

  defp org_role(%{memberships: memberships}, %{id: user_id}) when is_list(memberships) do
    case Enum.find(memberships, &(&1.user_id == user_id)) do
      %{role: role} when role in [:owner, :member, :guest] -> role
      _ -> :member
    end
  end

  defp org_role(_, _), do: :member

  defp user_display(%{display_name: name}) when is_binary(name) and name != "", do: name
  defp user_display(%{handle: handle}) when not is_nil(handle), do: "@" <> to_string(handle)
  defp user_display(_), do: ""

  defp user_initials(%{first_name: f, last_name: l}) when is_binary(f) and is_binary(l) and f != "" and l != "" do
    String.upcase(String.slice(f, 0, 1) <> String.slice(l, 0, 1))
  end

  defp user_initials(%{display_name: name}) when is_binary(name) and name != "" do
    name
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(2)
    |> Enum.map_join("", &String.slice(&1, 0, 1))
    |> String.upcase()
  end

  defp user_initials(%{handle: handle}) when not is_nil(handle) do
    String.upcase(String.slice(to_string(handle), 0, 2))
  end

  defp user_initials(_), do: "U"
end
