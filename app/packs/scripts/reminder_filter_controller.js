import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "checkbox"]

  connect() {
    this.applyFilter()
  }

  toggle() {
    this.applyFilter()
  }

  applyFilter() {
    if (this.hasCheckboxTarget) {
      const showAll = this.checkboxTarget.checked

      this.rowTargets.forEach((row) => {
        const isRead = row.dataset.read === "true"

        if (!showAll && isRead) {
          row.style.display = "none"
        } else {
          row.style.display = ""
        }
      })
    }
  }
}