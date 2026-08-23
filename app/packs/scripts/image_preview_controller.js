import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "image"]

  update() {
    this.imageTarget.src = this.selectTarget.value
  }
}