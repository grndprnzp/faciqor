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
    active_org = assigns[:org] || assigns[:current_org]
    assigns = assign(assigns, :active_org, active_org)

    ~H"""
    <div class="min-h-screen flex flex-col bg-[var(--fq-color-bg-app)]">
      <%!-- Permanent 14-Day Verification Warning Banner --%>
      <div
        :if={@current_user && is_nil(@current_user.email_confirmed_at)}
        id="verification-warning-banner"
        class="bg-[#FFFBEB] border-b border-[#F59E0B] px-4 sm:px-6 lg:px-8 py-2 text-[#92400E] flex items-center justify-between flex-wrap gap-2 text-xs"
      >
        <div class="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 shrink-0 text-[#D97706]">
            <path fill-rule="evenodd" d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495zM10 5a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 0110 5zm0 9a1 1 0 100-2 1 1 0 000 2z" clip-rule="evenodd" />
          </svg>
          <span class="font-semibold">Unbestätigte E-Mail-Adresse:</span>
          <span>
            Bitte bestätigen Sie Ihre E-Mail-Adresse innerhalb der nächsten <%= remaining_grace_days(@current_user) %> Tage.
            Bis zur Bestätigung sind CLI-/API-Zugriffe und ausgehende E-Mails deaktiviert.
          </span>
        </div>
        <button
          type="button"
          phx-click="resend_verification_email"
          class="font-medium underline hover:opacity-80 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB] rounded px-2 py-0.5 cursor-pointer"
        >
          Bestätigungs-E-Mail erneut senden
        </button>
      </div>

      <%!-- Tier 1 & Tier 2: GitHub-Inspired App Shell Header --%>
      <header :if={@current_user} class="bg-[var(--fq-color-bg-surface)] border-b border-[var(--fq-color-border)]">
        <%!-- Tier 1: Global Top Bar (Brand, Context Path / Switcher, Quick Create, User Profile & Sign-Out) --%>
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-14 flex items-center justify-between gap-4">
          <div class="flex items-center gap-2 sm:gap-3 min-w-0">
            <%!-- Brand Logo + Hub Link --%>
            <a
              href={~p"/dashboard"}
              class="inline-flex items-center gap-2 font-bold text-sm sm:text-base tracking-tight text-[var(--fq-color-primary)] hover:opacity-90 shrink-0 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB] rounded px-1 py-0.5"
            >
              <span class="inline-flex items-center justify-center w-7 h-7 rounded-md bg-[var(--fq-color-primary)] text-white font-bold text-xs fq-mono shadow-2xs">
                FQ
              </span>
              <span class="hidden sm:inline">Faciqor Hub</span>
            </a>

            <span class="text-[var(--fq-color-border-strong)] text-base select-none" aria-hidden="true">/</span>

            <%!-- Multi-Tenant Context Breadcrumb & Interactive Switcher --%>
            <div class="flex items-center gap-2 min-w-0" id="tenant-switcher">
              <%= if @active_org do %>
                <details class="relative group">
                  <summary class="list-none cursor-pointer inline-flex items-center gap-2 px-2.5 py-1 rounded-md border border-[var(--fq-color-border)] bg-[var(--fq-color-bg-muted)] hover:border-[var(--fq-color-border-strong)] transition-colors text-xs">
                    <%= if org_logo_url(@active_org) do %>
                      <img
                        src={org_logo_url(@active_org)}
                        alt="Logo"
                        class="w-4 h-4 rounded object-cover border border-[var(--fq-color-border)]"
                      />
                    <% else %>
                      <span class="inline-flex items-center justify-center w-4 h-4 rounded bg-[var(--fq-color-primary-subtle)] text-[var(--fq-color-primary)] font-bold text-[9px] fq-mono">
                        <%= String.upcase(String.slice(to_string(@active_org.handle), 0, 2)) %>
                      </span>
                    <% end %>
                    <span class="fq-mono font-semibold text-[var(--fq-color-text-main)] truncate max-w-[140px] sm:max-w-[200px]">
                      @<%= @active_org.handle %>
                    </span>
                    <.status_badge status={org_role(@active_org, @current_user)} />
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3.5 h-3.5 text-[var(--fq-color-text-muted)]">
                      <path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z" clip-rule="evenodd" />
                    </svg>
                  </summary>

                  <div class="absolute left-0 mt-1.5 w-72 rounded-lg border border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-surface)] shadow-lg z-40 divide-y divide-[var(--fq-color-border)]">
                    <div class="px-3 py-2 bg-[var(--fq-color-bg-muted)] text-[11px] font-semibold text-[var(--fq-color-text-muted)] flex items-center justify-between">
                      <span>Mandant wechseln</span>
                      <span class="fq-mono tabular-nums"><%= length(assigns[:user_orgs] || []) %></span>
                    </div>
                    <div class="max-h-60 overflow-y-auto py-1">
                      <a
                        :for={org_item <- assigns[:user_orgs] || [@active_org]}
                        href={~p"/orgs/#{org_item.handle}/facilities"}
                        class={[
                          "px-3 py-2 flex items-center justify-between gap-2 text-xs hover:bg-[var(--fq-color-bg-muted)] transition-colors",
                          if(org_item.id == @active_org.id, do: "bg-[var(--fq-color-primary-subtle)]/50 font-semibold", else: "")
                        ]}
                      >
                        <div class="flex items-center gap-2 min-w-0">
                          <span class="fq-mono text-[var(--fq-color-text-main)] truncate">@<%= org_item.handle %></span>
                        </div>
                        <.status_badge status={org_role(org_item, @current_user)} />
                      </a>
                    </div>
                    <div class="p-2 bg-[var(--fq-color-bg-muted)]/50">
                      <a
                        href={~p"/orgs/new"}
                        class="w-full inline-flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium text-[var(--fq-color-primary)] hover:bg-[var(--fq-color-primary-subtle)] transition-colors"
                      >
                        <span>+ Neue Organisation gründen</span>
                      </a>
                    </div>
                  </div>
                </details>
              <% else %>
                <span class="text-xs italic text-[var(--fq-color-text-muted)]">Keine Organisation gewählt</span>
              <% end %>

              <a
                href={~p"/orgs/new"}
                class="hidden md:inline-flex items-center gap-1 px-2.5 py-1 rounded-md border border-[var(--fq-color-border)] bg-[var(--fq-color-bg-surface)] hover:bg-[var(--fq-color-bg-muted)] text-xs font-medium text-[var(--fq-color-primary)] transition-colors"
                title="Neue Organisation gründen"
              >
                <span>+ Neue Organisation gründen</span>
              </a>
            </div>
          </div>

          <%!-- Right Global Controls: Quick Action, User Profile & Sign-Out --%>
          <nav class="flex items-center gap-2 sm:gap-3 shrink-0" aria-label="Globale Benutzernavigation">
            <a
              :if={@active_org}
              href={~p"/orgs/#{@active_org.handle}/facilities/new"}
              class="hidden lg:inline-flex items-center gap-1 px-2.5 py-1.5 rounded-md border border-[var(--fq-color-border-strong)] bg-[var(--fq-color-bg-surface)] hover:bg-[var(--fq-color-bg-muted)] text-xs font-medium text-[var(--fq-color-text-main)] transition-colors"
              title="Neues Objekt in dieser Organisation anlegen"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3.5 h-3.5 text-[var(--fq-color-primary)]">
                <path d="M10.75 4.75a.75.75 0 00-1.5 0v4.5h-4.5a.75.75 0 000 1.5h4.5v4.5a.75.75 0 001.5 0v-4.5h4.5a.75.75 0 000-1.5h-4.5v-4.5z" />
              </svg>
              <span>Objekt</span>
            </a>

            <a
              href={~p"/settings/profile"}
              class="text-xs font-medium text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)] flex items-center gap-2 px-2 py-1 rounded-md hover:bg-[var(--fq-color-bg-muted)] border border-transparent hover:border-[var(--fq-color-border)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2563EB]"
            >
              <%= if user_avatar_url(@current_user) do %>
                <img
                  src={user_avatar_url(@current_user)}
                  alt="Avatar"
                  class="w-6 h-6 rounded-full object-cover border border-[var(--fq-color-border)] shadow-2xs"
                />
              <% else %>
                <span class="inline-flex items-center justify-center w-6 h-6 rounded-full bg-[var(--fq-color-bg-muted)] border border-[var(--fq-color-border)] text-[var(--fq-color-text-main)] font-semibold text-[10px]">
                  <%= user_initials(@current_user) %>
                </span>
              <% end %>
              <span class="font-medium text-[var(--fq-color-text-main)] hidden sm:inline"><%= user_display(@current_user) %></span>
              <span class="text-[var(--fq-color-text-muted)] text-[11px] hidden xl:inline">(Profil &amp; CLI)</span>
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
              <span class="hidden sm:inline">Abmelden</span>
            </.link>
          </nav>
        </div>

        <%!-- Tier 2: GitHub-Style Contextual Underline Navigation Bar --%>
        <div class="bg-[var(--fq-color-bg-muted)]/60 border-t border-[var(--fq-color-border)]">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center gap-1 overflow-x-auto" id="context-subnav">
            <a
              href={~p"/dashboard"}
              class="inline-flex items-center gap-2 px-3 py-2.5 text-xs font-medium text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)] border-b-2 border-transparent hover:border-[var(--fq-color-border-strong)] transition-colors whitespace-nowrap"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 opacity-75">
                <path fill-rule="evenodd" d="M9.293 2.293a1 1 0 011.414 0l7 7A1 1 0 0117 11h-1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-3a1 1 0 00-1-1H9a1 1 0 00-1 1v3a1 1 0 01-1 1H5a1 1 0 01-1-1v-6H3a1 1 0 01-.707-1.707l7-7z" clip-rule="evenodd" />
              </svg>
              <span>Übersicht</span>
            </a>

            <%= if @active_org do %>
              <a
                href={~p"/orgs/#{@active_org.handle}/facilities"}
                class="inline-flex items-center gap-2 px-3 py-2.5 text-xs font-medium text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)] border-b-2 border-transparent hover:border-[var(--fq-color-border-strong)] transition-colors whitespace-nowrap"
              >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 opacity-75">
                  <path fill-rule="evenodd" d="M4 16.5v-13h-.25a.75.75 0 010-1.5h12.5a.75.75 0 010 1.5H16v13h.25a.75.75 0 010 1.5h-3.5a.75.75 0 01-.75-.75v-2.5a.75.75 0 00-.75-.75h-2.5a.75.75 0 00-.75.75v2.5a.75.75 0 01-.75.75h-3.5a.75.75 0 010-1.5H4zm3-11a.5.5 0 01.5-.5h1a.5.5 0 01.5.5v1a.5.5 0 01-.5.5h-1a.5.5 0 01-.5-.5v-1zM7.5 9a.5.5 0 00-.5.5v1a.5.5 0 00.5.5h1a.5.5 0 00.5-.5v-1a.5.5 0 00-.5-.5h-1zM11 5.5a.5.5 0 01.5-.5h1a.5.5 0 01.5.5v1a.5.5 0 01-.5.5h-1a.5.5 0 01-.5-.5v-1zm.5 3.5a.5.5 0 00-.5.5v1a.5.5 0 00.5.5h1a.5.5 0 00.5-.5v-1a.5.5 0 00-.5-.5h-1z" clip-rule="evenodd" />
                </svg>
                <span>Objekte &amp; Liegenschaften</span>
                <span class="px-1.5 py-0.2 rounded-full bg-[var(--fq-color-bg-surface)] border border-[var(--fq-color-border)] fq-mono text-[10px] text-[var(--fq-color-text-muted)]">
                  @<%= @active_org.handle %>
                </span>
              </a>

              <a
                href={~p"/orgs/#{@active_org.handle}/settings"}
                class="inline-flex items-center gap-2 px-3 py-2.5 text-xs font-medium text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)] border-b-2 border-transparent hover:border-[var(--fq-color-border-strong)] transition-colors whitespace-nowrap"
              >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 opacity-75">
                  <path fill-rule="evenodd" d="M7.84 1.804A1 1 0 018.82 1h2.36a1 1 0 01.98.804l.331 1.652a6.993 6.993 0 011.929 1.115l1.598-.54a1 1 0 011.186.447l1.18 2.044a1 1 0 01-.205 1.251l-1.267 1.113a7.047 7.047 0 010 2.228l1.267 1.113a1 1 0 01.206 1.25l-1.18 2.045a1 1 0 01-1.187.447l-1.598-.54a6.993 6.993 0 01-1.929 1.115l-.33 1.652a1 1 0 01-.98.804H8.82a1 1 0 01-.98-.804l-.331-1.652a6.993 6.993 0 01-1.929-1.115l-1.598.54a1 1 0 01-1.186-.447l-1.18-2.044a1 1 0 01.205-1.251l1.267-1.114a7.05 7.05 0 010-2.227L1.821 7.773a1 1 0 01-.206-1.25l1.18-2.045a1 1 0 011.187-.447l1.598.54A6.993 6.993 0 017.51 3.456l.33-1.652zM10 13a3 3 0 100-6 3 3 0 000 6z" clip-rule="evenodd" />
                </svg>
                <span>Mandanten-Einstellungen</span>
              </a>
            <% end %>

            <a
              href={~p"/settings/profile"}
              class="inline-flex items-center gap-2 px-3 py-2.5 text-xs font-medium text-[var(--fq-color-text-muted)] hover:text-[var(--fq-color-text-main)] border-b-2 border-transparent hover:border-[var(--fq-color-border-strong)] transition-colors whitespace-nowrap"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 opacity-75">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-5.5-2.5a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0zM10 12a5.99 5.99 0 00-4.793 2.39A6.483 6.483 0 0010 16.5a6.483 6.483 0 004.793-2.11A5.99 5.99 0 0010 12z" clip-rule="evenodd" />
              </svg>
              <span>Benutzerprofil &amp; CLI</span>
            </a>
          </div>
        </div>
      </header>

      <%!-- Flash Messages --%>
      <div class="max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8">
        <div
          :if={Phoenix.Flash.get(@flash, :info)}
          class="mt-4 p-3 rounded-md bg-[#ECFDF5] border border-[#6EE7B7] text-[#065F46] text-xs font-medium flex items-center justify-between"
        >
          <span><%= Phoenix.Flash.get(@flash, :info) %></span>
        </div>
        <div
          :if={Phoenix.Flash.get(@flash, :error)}
          class="mt-4 p-3 rounded-md bg-[#FEF2F2] border border-[#FCA5A5] text-[#991B1B] text-xs font-medium flex items-center justify-between"
        >
          <span><%= Phoenix.Flash.get(@flash, :error) %></span>
        </div>
      </div>

      <main class="flex-1 mx-auto w-full max-w-7xl px-4 sm:px-6 lg:px-8 py-6">
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

  defp user_avatar_url(%{avatar_blob: %{variants: %{"64" => key}}}) when is_binary(key),
    do: Faciqor.Media.Storage.public_url(key)

  defp user_avatar_url(%{avatar_blob: %{variants: %{"128" => key}}}) when is_binary(key),
    do: Faciqor.Media.Storage.public_url(key)

  defp user_avatar_url(%{avatar_blob: %{key: key}}) when is_binary(key),
    do: Faciqor.Media.Storage.public_url(key)

  defp user_avatar_url(_), do: nil

  defp org_logo_url(%{logo_blob: %{variants: %{"64" => key}}}) when is_binary(key),
    do: Faciqor.Media.Storage.public_url(key)

  defp org_logo_url(%{logo_blob: %{variants: %{"128" => key}}}) when is_binary(key),
    do: Faciqor.Media.Storage.public_url(key)

  defp org_logo_url(%{logo_blob: %{key: key}}) when is_binary(key),
    do: Faciqor.Media.Storage.public_url(key)

  defp org_logo_url(_), do: nil
end
