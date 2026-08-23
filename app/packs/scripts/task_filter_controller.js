// app/javascript/controllers/task_filter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const showOnlyAssigned = event.target.checked

    const rows = document.querySelectorAll(".task-row")

    rows.forEach(row => {
      const assigned = row.dataset.assigned === "true"

      if (showOnlyAssigned && !assigned) {
        row.style.display = "none"
      } else {
        row.style.display = ""
      }
    })
  }
}