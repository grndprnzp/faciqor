import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

import Cropper from "./vendor/cropper.js"

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

Hooks.ImageCropper = {
  mounted() {
    const fileInput = this.el.querySelector("input[type=file]")
    const modalId = this.el.dataset.modalId || "cropper-modal"
    const previewId = this.el.dataset.previewId || "cropper-preview-img"
    const confirmBtnId = this.el.dataset.confirmBtnId || "cropper-confirm-btn"
    const cancelBtnId = this.el.dataset.cancelBtnId || "cropper-cancel-btn"

    let cropper = null

    if (!fileInput) return

    fileInput.addEventListener("change", (e) => {
      const file = e.target.files[0]
      if (!file) return

      if (file.size > 5 * 1024 * 1024) {
        alert("Die Datei darf maximal 5MB groß sein.")
        fileInput.value = ""
        return
      }

      const modal = document.getElementById(modalId)
      const previewImg = document.getElementById(previewId)
      if (!modal || !previewImg) return

      const reader = new FileReader()
      reader.onload = (event) => {
        if (cropper) {
          cropper.destroy()
          cropper = null
        }

        modal.classList.remove("hidden")

        previewImg.onload = () => {
          cropper = new Cropper(previewImg, {
            aspectRatio: 1,
            viewMode: 1,
            autoCropArea: 0.9,
            responsive: true,
            guides: true,
            center: true,
            highlight: false,
            cropBoxMovable: true,
            cropBoxResizable: true
          })
        }
        previewImg.src = event.target.result
      }
      reader.readAsDataURL(file)
    })

    this.confirmHandler = (e) => {
      const btn = e.target.closest(`#${confirmBtnId}`)
      if (!btn) return
      if (!cropper) return

      const canvas = cropper.getCroppedCanvas({
        minWidth: 512,
        minHeight: 512,
        width: 512,
        height: 512,
        imageSmoothingEnabled: true,
        imageSmoothingQuality: "high"
      })

      if (!canvas) {
        alert("Das Bild konnte nicht zugeschnitten werden. Bitte versuchen Sie es erneut.")
        return
      }

      const base64Data = canvas.toDataURL("image/png")
      const targetEvent = this.el.dataset.event || "save_cropped_image"

      this.pushEvent(targetEvent, {
        data: base64Data,
        content_type: "image/png"
      })

      const modal = document.getElementById(modalId)
      if (modal) modal.classList.add("hidden")
      if (cropper) {
        cropper.destroy()
        cropper = null
      }
      fileInput.value = ""
    }

    this.cancelHandler = (e) => {
      const btn = e.target.closest(`#${cancelBtnId}`)
      if (!btn) return

      const modal = document.getElementById(modalId)
      if (modal) modal.classList.add("hidden")
      if (cropper) {
        cropper.destroy()
        cropper = null
      }
      fileInput.value = ""
    }

    document.addEventListener("click", this.confirmHandler)
    document.addEventListener("click", this.cancelHandler)
  },

  destroyed() {
    if (this.confirmHandler) document.removeEventListener("click", this.confirmHandler)
    if (this.cancelHandler) document.removeEventListener("click", this.cancelHandler)
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

liveSocket.connect()
window.liveSocket = liveSocket
