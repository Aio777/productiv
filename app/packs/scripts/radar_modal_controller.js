import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static targets = ["modal", "title", "canvas", "slider"]

  connect() {
    this.chart = null
  }

  open(event) {
    const button = event.currentTarget
    const memberName = button.dataset.memberName
    const labels = JSON.parse(button.dataset.radarLabels || "[]")
    const scores = JSON.parse(button.dataset.radarScores || "[]")

    this.titleTarget.textContent = `${memberName} Radar Chart`
    this.modalTarget.classList.remove("hidden")
    this.renderChart(labels, scores)
  }

  openFromSliders(event) {
    const button = event.currentTarget
    const memberName = button.dataset.memberName
    const labels = JSON.parse(button.dataset.radarLabels || "[]")
    const scores = this.sliderTargets.map((slider) => Number(slider.value || 0))

    this.titleTarget.textContent = `${memberName} Radar Chart`
    this.modalTarget.classList.remove("hidden")
    this.renderChart(labels, scores)
  }

  close() {
    this.modalTarget.classList.add("hidden")

    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  renderChart(labels, scores) {
    if (this.chart) {
      this.chart.destroy()
    }

    const ctx = this.canvasTarget.getContext("2d")

    this.chart = new Chart(ctx, {
      type: "radar",
      data: {
        labels: labels,
        datasets: [
          {
            label: "Radar Score",
            data: scores
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          r: {
            beginAtZero: true,
            min: 0,
            max: 5,
            ticks: {
              stepSize: 1
            }
          }
        }
      }
    })
  }
}