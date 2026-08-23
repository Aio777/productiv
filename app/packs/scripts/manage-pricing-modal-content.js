// TODO: Refactor manage-pricing-modal-content.js and
// manage-feature-modal-content.js, as they both have identical content in their
// JavaScript files
import ahoy from "ahoy.js";

const pricingModal = document.getElementById('pricingModal')
let previousEventName = null

if (pricingModal) {
  pricingModal.addEventListener('show.bs.modal', event => {
    const button = event.relatedTarget
    const pricingViewEventName = button.getAttribute('data-bs-event-view-name')

    if (pricingViewEventName !== previousEventName) {
      previousEventName = pricingViewEventName
      ahoy.track(pricingViewEventName, {language: "JavaScript"})
    }

    const modalTitle = pricingModal.querySelector('.modal-title')
    const modalBody = pricingModal.querySelector('.modal-body')
    const name = button.getAttribute('data-bs-name')
    const message = button.getAttribute('data-bs-message')

    modalTitle.textContent = `${name}`
    modalBody.innerHTML = `${message}`
  })
}
