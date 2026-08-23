import ahoy from "ahoy.js";

const registerInterestModal = document.getElementById('registerInterestModal')
let previousEventName = null

if (registerInterestModal) {
  registerInterestModal.addEventListener('show.bs.modal', event => {
    const button = event.relatedTarget
    const registerInterestViewEventName = button.getAttribute(
      'data-bs-event-view-name'
    )

    if (registerInterestViewEventName !== previousEventName) {
      previousEventName = registerInterestViewEventName
      ahoy.track(registerInterestViewEventName, {language: "JavaScript"})
    }
  })
}