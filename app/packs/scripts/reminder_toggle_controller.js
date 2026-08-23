import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  
  toggle(event) {
    const enabled = event.target.checked

    if (enabled) {
      this.inputTarget.disabled = false
      this.inputTarget.classList.remove("reminder-disabled")
    } else {
      this.inputTarget.disabled = true
      this.inputTarget.value = ""
      this.inputTarget.classList.add("reminder-disabled")
    }
  }
}