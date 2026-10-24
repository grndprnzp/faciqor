defmodule FaciqorWeb.VerifyEmailRequiredLive do
  use FaciqorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("resend_verification_email", _params, socket) do
    {:noreply, put_flash(socket, :info, "Bestätigungs-E-Mail wurde erneut an #{socket.assigns.current_user.email} gesendet.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto mt-12 bg-[var(--fq-color-bg-surface)] border border-[#F59E0B] rounded-lg p-6 space-y-4">
      <div class="flex items-center gap-2 text-[#92400E]">
        <h1 class="text-lg font-bold">E-Mail-Verifizierung erforderlich</h1>
      </div>
      <p class="text-sm text-[var(--fq-color-text-muted)]">
        Die 14-tägige Kulanzfrist für Ihr Konto (<span class="fq-mono font-medium"><%= @current_user.email %></span>) ist abgelaufen.
        Bitte klicken Sie auf den Bestätigungslink in Ihrer E-Mail, um den Zugriff auf Faciqor Hub wieder freizuschalten.
      </p>
      <div class="pt-2">
        <.button type="button" phx-click="resend_verification_email">
          Bestätigungs-E-Mail erneut senden
        </.button>
      </div>
    </div>
    """
  end
end
