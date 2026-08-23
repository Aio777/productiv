import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  disable(event) {
    const container = event.target.closest(".mt-3")
    container.querySelectorAll("button").forEach(btn => {
      btn.disabled = true
      btn.classList.add("opacity-50", "cursor-not-allowed")
    })
  }
}
