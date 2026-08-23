import ahoy from "ahoy.js";

const featuresModal = document.getElementById("featuresModal");

if (featuresModal) {
  featuresModal.addEventListener("show.bs.modal", (event) => {
    const button = event.relatedTarget;
    const featureViewEventName = button.getAttribute("data-bs-event-view-name");

    ahoy.track(featureViewEventName, { language: "JavaScript" });

    const modalTitle = featuresModal.querySelector(".modal-title");
    const modalBody = featuresModal.querySelector(".modal-body");
    const modalImage = featuresModal.querySelector(".modal-image");

    const name = button.getAttribute("data-bs-name");
    const message = button.getAttribute("data-bs-message");
    var image = button.getAttribute("data-bs-image");

    modalTitle.innerText = `${name}`;
    modalBody.innerHTML = `${message}`;

    if (image !== "none") {
      modalImage.innerHTML = image;
    } else {
      modalImage.innerText = "Design coming soon!";
    }

    featuresModal
      .querySelectorAll("[data-social-media-share-button]")
      .forEach((button) => {
        button.dataset.sharedFeatureMessage =
          featuresModal.dataset.sharedFeaturePrefixName + " '" + name + "'";
      });
  });
}
