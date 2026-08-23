import ProgressBar from "progressbar.js"

function initProjectProgressBars() {
  document.querySelectorAll(".project-progress-bar").forEach((element) => {
    if (element.dataset.initialized === "true") return

    const progress = Number(element.dataset.progress || 0)
    const value = Math.min(Math.max(progress, 0), 100) / 100

    const bar = new ProgressBar.Line(element, {
      text: {
        value: `<span>${progress}% Complete</span>`,
        className: "progress-bar-label"
      },

      strokeWidth: 6,
      trailWidth: 6,
      easing: "easeInOut",
      duration: 900,
      color: "#14b8a6",
      trailColor: "#e5e7eb",
      svgStyle: { width: "100%", height: "100%" }
    })

    bar.animate(value)
    element.dataset.initialized = "true"
  })
}

document.addEventListener("DOMContentLoaded", initProjectProgressBars)
document.addEventListener("turbo:load", initProjectProgressBars)