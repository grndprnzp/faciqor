import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}
Hooks.CopyToClipboard = {
  mounted() {
    this.el.addEventListener("click", () => {
      let text = this.el.dataset.clipboardText
      if (text) {
        navigator.clipboard.writeText(text).then(() => {
          let originalHtml = this.el.innerHTML
          this.el.innerHTML = "<span>✓ Kopiert!</span>"
          setTimeout(() => { this.el.innerHTML = originalHtml }, 2000)
        }).catch(err => {
          console.error("Clipboard copy failed:", err)
        })
      }
    })
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

liveSocket.connect()
window.liveSocket = liveSocket
