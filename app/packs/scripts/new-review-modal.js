import ahoy from "ahoy.js";

const newReviewModal = document.getElementById('newReviewModal')
let previousEventName = null

if (newReviewModal) {
  newReviewModal.addEventListener('show.bs.modal', event => {
    const button = event.relatedTarget
    const newReviewViewEventName = button.getAttribute(
      'data-bs-event-view-name'
    )

    if (newReviewViewEventName !== previousEventName) {
      previousEventName = newReviewViewEventName
      ahoy.track(newReviewViewEventName, {language: "JavaScript"})
    }
  })
}