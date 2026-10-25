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

Hooks.FacilityMap = {
  mounted() {
    this.canvasEl = this.el.querySelector("#facility-map-canvas") || this.el
    this.tileUrl = this.el.dataset.tileUrl || "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    this.attribution = this.el.dataset.attribution || ""
    this.editable = this.el.dataset.editable === "true"

    try {
      this.addresses = JSON.parse(this.el.dataset.addresses || "[]")
    } catch (_) {
      this.addresses = []
    }

    try {
      this.polygon = JSON.parse(this.el.dataset.polygon || "[]")
    } catch (_) {
      this.polygon = []
    }

    this.zoom = 17
    this.draggingIdx = null

    this.initDOM()
    this.renderMap()

    this.handleEvent("facility_map:update", ({addresses, polygon}) => {
      this.addresses = addresses || []
      this.polygon = polygon || []
      this.renderMap()
    })

    this.onResize = () => this.renderMap()
    window.addEventListener("resize", this.onResize)
  },

  destroyed() {
    if (this.onResize) window.removeEventListener("resize", this.onResize)
    if (this.onMouseMove) document.removeEventListener("mousemove", this.onMouseMove)
    if (this.onMouseUp) document.removeEventListener("mouseup", this.onMouseUp)
  },

  initDOM() {
    this.canvasEl.innerHTML = ""
    this.canvasEl.style.position = "relative"
    this.canvasEl.style.userSelect = "none"

    this.tileLayer = document.createElement("div")
    this.tileLayer.style.position = "absolute"
    this.tileLayer.style.inset = "0"
    this.tileLayer.style.overflow = "hidden"
    this.canvasEl.appendChild(this.tileLayer)

    this.svgOverlay = document.createElementNS("http://www.w3.org/2000/svg", "svg")
    this.svgOverlay.style.position = "absolute"
    this.svgOverlay.style.inset = "0"
    this.svgOverlay.style.width = "100%"
    this.svgOverlay.style.height = "100%"
    this.canvasEl.appendChild(this.svgOverlay)

    this.markerLayer = document.createElement("div")
    this.markerLayer.style.position = "absolute"
    this.markerLayer.style.inset = "0"
    this.markerLayer.style.pointerEvents = "none"
    this.canvasEl.appendChild(this.markerLayer)

    this.attrEl = document.createElement("div")
    this.attrEl.style.position = "absolute"
    this.attrEl.style.bottom = "4px"
    this.attrEl.style.right = "8px"
    this.attrEl.style.padding = "2px 6px"
    this.attrEl.style.background = "rgba(255,255,255,0.85)"
    this.attrEl.style.borderRadius = "4px"
    this.attrEl.style.fontSize = "10px"
    this.attrEl.innerHTML = this.attribution
    this.canvasEl.appendChild(this.attrEl)

    this.onMouseMove = (e) => {
      if (this.draggingIdx === null) return
      const rect = this.canvasEl.getBoundingClientRect()
      const px = e.clientX - rect.left
      const py = e.clientY - rect.top
      const {lat, lon} = this.pixelToLatLon(px, py, rect.width, rect.height)
      this.polygon[this.draggingIdx] = {
        latitude: lat.toFixed(7),
        longitude: lon.toFixed(7)
      }
      this.renderVectorAndMarkers(rect.width, rect.height)
    }

    this.onMouseUp = () => {
      if (this.draggingIdx !== null) {
        this.draggingIdx = null
        this.pushEvent("update_geofence_polygon", {polygon: this.polygon})
      }
    }

    document.addEventListener("mousemove", this.onMouseMove)
    document.addEventListener("mouseup", this.onMouseUp)
  },

  computeCenter() {
    const pts = [
      ...this.addresses.map(a => ({lat: parseFloat(a.latitude), lon: parseFloat(a.longitude)})),
      ...this.polygon.map(p => ({lat: parseFloat(p.latitude), lon: parseFloat(p.longitude)}))
    ].filter(p => !isNaN(p.lat) && !isNaN(p.lon))

    if (pts.length === 0) {
      return {lat: 52.5200066, lon: 13.4049540}
    }

    const minLat = Math.min(...pts.map(p => p.lat))
    const maxLat = Math.max(...pts.map(p => p.lat))
    const minLon = Math.min(...pts.map(p => p.lon))
    const maxLon = Math.max(...pts.map(p => p.lon))
    return {lat: (minLat + maxLat) / 2, lon: (minLon + maxLon) / 2}
  },

  latLonToTileXY(lat, lon, z) {
    const n = Math.pow(2, z)
    const x = ((lon + 180) / 360) * n
    const latRad = (lat * Math.PI) / 180
    const y = ((1 - Math.log(Math.tan(latRad) + 1 / Math.cos(latRad)) / Math.PI) / 2) * n
    return {x, y}
  },

  tileXYToLatLon(x, y, z) {
    const n = Math.pow(2, z)
    const lon = (x / n) * 360 - 180
    const latRad = Math.atan(Math.sinh(Math.PI * (1 - (2 * y) / n)))
    const lat = (latRad * 180) / Math.PI
    return {lat, lon}
  },

  latLonToPixel(lat, lon, width, height) {
    const centerTile = this.latLonToTileXY(this.center.lat, this.center.lon, this.zoom)
    const ptTile = this.latLonToTileXY(lat, lon, this.zoom)
    return {
      x: width / 2 + (ptTile.x - centerTile.x) * 256,
      y: height / 2 + (ptTile.y - centerTile.y) * 256
    }
  },

  pixelToLatLon(px, py, width, height) {
    const centerTile = this.latLonToTileXY(this.center.lat, this.center.lon, this.zoom)
    const tileX = centerTile.x + (px - width / 2) / 256
    const tileY = centerTile.y + (py - height / 2) / 256
    return this.tileXYToLatLon(tileX, tileY, this.zoom)
  },

  renderMap() {
    const rect = this.canvasEl.getBoundingClientRect()
    const width = rect.width || 800
    const height = rect.height || 384

    this.center = this.computeCenter()
    this.renderTiles(width, height)
    this.renderVectorAndMarkers(width, height)
  },

  renderTiles(width, height) {
    this.tileLayer.innerHTML = ""
    const centerTile = this.latLonToTileXY(this.center.lat, this.center.lon, this.zoom)
    const startX = Math.floor(centerTile.x - width / 512) - 1
    const endX = Math.ceil(centerTile.x + width / 512) + 1
    const startY = Math.floor(centerTile.y - height / 512) - 1
    const endY = Math.ceil(centerTile.y + height / 512) + 1
    const subdomains = ["a", "b", "c"]

    for (let tx = startX; tx <= endX; tx++) {
      for (let ty = startY; ty <= endY; ty++) {
        const img = document.createElement("img")
        const s = subdomains[Math.abs(tx + ty) % subdomains.length]
        img.src = this.tileUrl
          .replace("{s}", s)
          .replace("{z}", this.zoom)
          .replace("{x}", tx)
          .replace("{y}", ty)
        img.alt = ""
        img.style.position = "absolute"
        img.style.width = "256px"
        img.style.height = "256px"
        img.style.left = `${Math.round(width / 2 + (tx - centerTile.x) * 256)}px`
        img.style.top = `${Math.round(height / 2 + (ty - centerTile.y) * 256)}px`
        this.tileLayer.appendChild(img)
      }
    }
  },

  renderVectorAndMarkers(width, height) {
    this.svgOverlay.innerHTML = ""
    this.markerLayer.innerHTML = ""

    if (this.polygon.length >= 3) {
      const polyPts = this.polygon.map(p =>
        this.latLonToPixel(parseFloat(p.latitude), parseFloat(p.longitude), width, height)
      )
      const polyEl = document.createElementNS("http://www.w3.org/2000/svg", "polygon")
      polyEl.setAttribute("points", polyPts.map(pt => `${pt.x},${pt.y}`).join(" "))
      polyEl.setAttribute("fill", "rgba(37, 99, 235, 0.18)")
      polyEl.setAttribute("stroke", "#2563EB")
      polyEl.setAttribute("stroke-width", "2")
      this.svgOverlay.appendChild(polyEl)

      if (this.editable) {
        polyPts.forEach((pt, idx) => {
          const handle = document.createElementNS("http://www.w3.org/2000/svg", "circle")
          handle.setAttribute("cx", pt.x)
          handle.setAttribute("cy", pt.y)
          handle.setAttribute("r", "6")
          handle.setAttribute("fill", "#FFFFFF")
          handle.setAttribute("stroke", "#2563EB")
          handle.setAttribute("stroke-width", "2")
          handle.style.cursor = "grab"
          handle.addEventListener("mousedown", (e) => {
            e.stopPropagation()
            this.draggingIdx = idx
          })
          this.svgOverlay.appendChild(handle)
        })
      }
    }

    this.addresses.forEach((addr) => {
      const lat = parseFloat(addr.latitude)
      const lon = parseFloat(addr.longitude)
      if (isNaN(lat) || isNaN(lon)) return

      const pt = this.latLonToPixel(lat, lon, width, height)
      const pin = document.createElement("div")
      pin.style.position = "absolute"
      pin.style.left = `${pt.x}px`
      pin.style.top = `${pt.y}px`
      pin.style.transform = "translate(-50%, -100%)"
      pin.style.background = addr.is_primary ? "#2563EB" : "#0F172A"
      pin.style.color = "#FFFFFF"
      pin.style.padding = "2px 6px"
      pin.style.borderRadius = "4px"
      pin.style.fontSize = "11px"
      pin.style.fontWeight = "600"
      pin.style.whiteSpace = "nowrap"
      pin.style.boxShadow = "0 1px 3px rgba(0,0,0,0.3)"
      pin.textContent = `${addr.street} ${addr.house_number}`
      this.markerLayer.appendChild(pin)
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
