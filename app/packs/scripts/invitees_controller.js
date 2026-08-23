import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "hiddenContainer"]

  connect() {
    this.emails = []
  }

  handleKeydown(event) {
    if (!["Enter", ",", "Tab"].includes(event.key)) return

    event.preventDefault()

    const raw = this.inputTarget.value.trim().replace(/,$/, "")
    if (!raw) return
    if (!this.validEmail(raw)) return

    const email = raw.toLowerCase()
    if (this.emails.includes(email)) {
      this.inputTarget.value = ""
      return
    }

    this.emails.push(email)
    this.inputTarget.value = ""
    this.render()
    this.sync()
  }

  render() {
    this.listTarget.innerHTML = ""

    this.emails.forEach((email) => {
      const chip = document.createElement("div")
      chip.className = "shared-project-invite-chip"

      const badge = document.createElement("span")
      badge.className = "shared-project-invite-chip__badge"
      badge.textContent = email.slice(0, 2).toUpperCase()

      const text = document.createElement("span")
      text.className = "shared-project-invite-chip__text"
      text.textContent = email

      const remove = document.createElement("button")
      remove.type = "button"
      remove.className = "shared-project-invite-chip__remove"
      remove.textContent = "×"
      remove.addEventListener("click", () => {
        this.emails = this.emails.filter((e) => e !== email)
        this.render()
        this.sync()
      })

      chip.appendChild(badge)
      chip.appendChild(text)
      chip.appendChild(remove)

      this.listTarget.appendChild(chip)
    })
  }

  sync() {
    this.hiddenContainerTarget.innerHTML = ""

    this.emails.forEach((email) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "team_project[invite_emails][]"
      input.value = email
      this.hiddenContainerTarget.appendChild(input)
    })
  }

  validEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
  }
}