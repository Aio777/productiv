import { Controller } from "@hotwired/stimulus"
import ahoy from "ahoy.js"

const STORAGE_KEY = "productivPomodoroState"

export default class extends Controller {
  static targets = ["time", "toggleButton"]

  connect() {
    this.interval = null
    this.handleUpdate = this.handleUpdate.bind(this)

    window.addEventListener("floating-pomodoro-updated", this.handleUpdate)
    this.renderFromStorage()
  }

  disconnect() {
    this.stop()
    window.removeEventListener("floating-pomodoro-updated", this.handleUpdate)
  }

  handleUpdate() {
    this.renderFromStorage()
  }

  toggle() {
    const state = this.readState()
    if (!state || state.completed) return

    if (state.running && state.endAt) {
      state.running = false
      state.pausedRemaining = this.calculateRemaining(state.endAt)
      state.endAt = null
    } else {
      ahoy.track(
        this.toggleButtonTarget.dataset.bsEventViewName,
        {language: "JavaScript"}
      )

      const remaining = state.pausedRemaining || state.duration || 1500
      state.running = true
      state.endAt = Date.now() + (remaining * 1000)
      state.pausedRemaining = null
    }

    this.writeState(state)
    this.renderFromStorage()
  }

  reset() {
    const state = this.readState()
    if (!state) return

    state.running = false
    state.endAt = null
    state.completed = false
    state.pausedRemaining = state.duration || 1500

    this.writeState(state)
    this.renderFromStorage()
  }

  hide() {
    const state = this.readState()
    if (!state) return

    state.enabled = false
    this.writeState(state)
    this.renderFromStorage()
  }

  renderFromStorage() {
    const state = this.readState()

    if (!state || !state.enabled) {
      this.element.classList.add("d-none")
      this.stop()
      return
    }

    this.element.classList.remove("d-none")

    let remaining
    if (state.running && state.endAt) {
      remaining = this.calculateRemaining(state.endAt)
    } else {
      remaining = state.pausedRemaining || state.duration || 1500
    }

    if (state.running && remaining <= 0) {
      state.running = false
      state.endAt = null
      state.completed = true
      state.pausedRemaining = 0
      this.writeState(state)
      this.stop()
      this.timeTarget.textContent = "0:00"
      this.toggleButtonTarget.innerHTML = '<i class="bi bi-play-fill", aria-hidden="true"></i>'
      this.toggleButtonTarget.setAttribute('aria-label', 'Start Timer');
      alert("Pomodoro complete")
      return
    }

    this.timeTarget.textContent = this.formatTime(remaining)

    if (state.running) {
      this.toggleButtonTarget.innerHTML = '<i class="bi bi-pause-fill", aria-hidden="true"></i>'
      this.toggleButtonTarget.setAttribute('aria-label', 'Pause Timer');
      this.startTicking()
    } else {
      this.toggleButtonTarget.innerHTML = '<i class="bi bi-play-fill", aria-hidden="true"></i>'
      this.toggleButtonTarget.setAttribute('aria-label', 'Start Timer');
      this.stop()
    }
  }

  startTicking() {
    this.stop()

    this.interval = setInterval(() => {
      this.renderFromStorage()
    }, 1000)
  }

  stop() {
    clearInterval(this.interval)
    this.interval = null
  }

  readState() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY)
      return raw ? JSON.parse(raw) : null
    } catch {
      return null
    }
  }

  writeState(state) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
    window.dispatchEvent(new CustomEvent("floating-pomodoro-updated"))
  }

  calculateRemaining(endAt) {
    return Math.max(0, Math.ceil((endAt - Date.now()) / 1000))
  }

  formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    return `${minutes}:${seconds.toString().padStart(2, "0")}`
  }
}