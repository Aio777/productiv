import { Controller } from "@hotwired/stimulus"
import ahoy from "ahoy.js"

const STORAGE_KEY = "productivPomodoroState"

export default class extends Controller {
  static targets = ["time", "durationLabel", "controls", "toggleButton"]
  static values = {
    min: Number,
    max: Number,
    increase: Number,
    duration: Number
  }

  connect() {
    const savedState = this.readState()

    if (savedState) {
      this.duration = savedState.duration
      this.completed = savedState.completed || false

      if (savedState.running && savedState.endAt) {
        this.remaining = this.calculateRemaining(savedState.endAt)
        if (this.remaining <= 0) {
          this.remaining = 0
          this.completed = true
          this.interval = null
          this.saveState()
        } else {
          this.startInterval(savedState.endAt)
        }
      } else {
        this.remaining = savedState.pausedRemaining || savedState.duration || 1500
        this.interval = null
      }
    } else {
      this.duration = this.hasDurationValue ? this.durationValue : 1500
      this.remaining = this.duration
      this.interval = null
      this.completed = false
    }

    this.setPlayIcon()
    this.render()
  }

  disconnect() {
    this.stop()
  }

  increase() {
    if (this.interval) return
    if (this.duration >= this.maxValue) return

    this.duration += this.increaseValue
    this.remaining = this.duration
    this.completed = false
    this.saveState()
    this.render()
  }

  decrease() {
    if (this.interval) return
    if (this.duration <= this.minValue) return

    this.duration -= this.increaseValue
    this.remaining = this.duration
    this.completed = false
    this.saveState()
    this.render()
  }

  toggle() {
    if (this.completed) return

    if (this.interval) {
      this.pause()
    } else {
      this.start()
    }
  }
 
  start() {
    if (this.interval) return

    ahoy.track(
      this.toggleButtonTarget.dataset.bsEventViewName,
      {language: "JavaScript"}
    )

    const endAt = Date.now() + (this.remaining * 1000)

    this.controlsTarget.classList.add("d-none")
    this.setPauseIcon()
    this.startInterval(endAt)
    this.saveState(true, endAt)
  }

  startInterval(endAt) {
    this.stop()

    this.interval = setInterval(() => {
      this.remaining = this.calculateRemaining(endAt)

      if (this.remaining <= 0) {
        this.complete()
        return
      }

      this.render()
    }, 1000)
  }

  complete() {
    this.stop()
    this.remaining = 0
    this.completed = true

    this.toggleButtonTarget.classList.add("d-none")
    this.controlsTarget.classList.remove("d-none")

    this.saveState(false, null)
    this.render()
    alert("Pomodoro complete")
  }

  pause() {
    this.stop()
    this.setPlayIcon()
    this.saveState(false, null)
  }

  reset() {
    this.stop()
    this.remaining = this.duration
    this.completed = false
    this.toggleButtonTarget.classList.remove("d-none")
    this.controlsTarget.classList.remove("d-none")
    this.setPlayIcon()
    this.saveState(false, null)
    this.render()
  }

  stop() {
    clearInterval(this.interval)
    this.interval = null
  }

  setPlayIcon() {
    this.toggleButtonTarget.innerHTML =
      '<i class="bi bi-play-fill fs-4", aria-hidden="true"></i>'
    this.toggleButtonTarget.setAttribute('aria-label', 'Start Timer');
  }

  setPauseIcon() {
    this.toggleButtonTarget.innerHTML =
      '<i class="bi bi-pause-fill fs-4", aria-hidden="true"></i>'
    this.toggleButtonTarget.setAttribute('aria-label', 'Pause Timer');
  }

  render() {
    const minutes = Math.floor(this.remaining / 60)
    const seconds = this.remaining % 60

    this.timeTarget.textContent =
      `${minutes}:${seconds.toString().padStart(2, "0")}`

    this.durationLabelTarget.textContent =
      `${this.duration / 60} min`
  }

  setDuration(seconds) {
    this.stop()
    this.duration = seconds
    this.remaining = seconds
    this.completed = false
    this.toggleButtonTarget.classList.remove("d-none")
    this.controlsTarget.classList.remove("d-none")
    this.setPlayIcon()
    this.saveState(false, null)
    this.render()
  }

  enableFloating() {
    const state = this.readState() || {}
    state.enabled = true
    state.duration = this.duration
    state.completed = this.completed

    if (this.interval) {
      state.running = true
      state.endAt = Date.now() + (this.remaining * 1000)
      state.pausedRemaining = null
    } else {
      state.running = false
      state.endAt = null
      state.pausedRemaining = this.remaining
    }

    localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
    window.dispatchEvent(new CustomEvent("floating-pomodoro-updated"))
  }

  saveState(running = false, endAt = null) {
    const state = {
      enabled: this.readState()?.enabled || false,
      duration: this.duration,
      completed: this.completed,
      running: running,
      endAt: endAt,
      pausedRemaining: running ? null : this.remaining
    }

    localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
    window.dispatchEvent(new CustomEvent("floating-pomodoro-updated"))
  }

  readState() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY)
      return raw ? JSON.parse(raw) : null
    } catch {
      return null
    }
  }

  calculateRemaining(endAt) {
    return Math.max(0, Math.ceil((endAt - Date.now()) / 1000))
  }
}