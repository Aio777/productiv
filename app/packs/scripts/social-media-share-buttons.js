import ahoy from "ahoy.js";

const DEMO_SITE_URL = "https://team01.demo1.genesys.shefcompsci.org.uk/";

const featuresModal = document.getElementById("featuresModal");

if (featuresModal) {
  featuresModal
    .querySelectorAll("[data-social-media-share-button]")
    .forEach((shareButton) => {
      shareButton.addEventListener("click", () => {
        ahoy.track(shareButton.dataset.sharedFeatureMessage, {
          language: "JavaScript",
        });
        shareButton.href = updateHref(
          shareButton.href,
          shareButton.dataset.featureName,
        );
      });
    });
}

function updateHref(href, featureName) {
  const featureMessage = `This '${featureName}' feature is really cool! Check this app out:`;

  let updatedHref = href;

  if (href.includes("twitter")) {
    const start = href.indexOf("text=") + "text=".length;
    const end = href.indexOf("&url=", start);

    updatedHref =
      href.slice(0, start) +
      encodeURIComponent(featureMessage) +
      href.slice(end);
  } else if (href.includes("wa.me")) {
    const fullText = `${featureMessage} \n\n ${DEMO_SITE_URL}`;
    const encodedText = encodeURIComponent(fullText);

    updatedHref = `https://wa.me/?text=${encodedText}`;
  } else if (href.includes("reddit")) {
    updatedHref = replaceStringSection(
      href,
      "title=",
      "&url=",
      encodeURIComponent(featureMessage),
    );
  } else if (href.includes("mail")) {
    const subject = "Check this app out!";
    const body = `This '${featureName}' feature is really cool! Check this app out:\n\n${DEMO_SITE_URL}`;

    updatedHref =
      `https://mail.google.com/mail/?view=cm&fs=1` +
      `&su=${encodeURIComponent(subject)}` +
      `&body=${encodeURIComponent(body)}`;
  }
  return updatedHref;
}

function replaceStringSection(
  string,
  start_substring,
  end_substring,
  new_string_section,
) {
  const start = string.indexOf(start_substring) + start_substring.length;
  const end = string.indexOf(end_substring);

  const new_start_substring = string.substring(0, start);
  const new_end_substring = string.substring(end);

  const new_string =
    new_start_substring + new_string_section + new_end_substring;
  return new_string;
}
