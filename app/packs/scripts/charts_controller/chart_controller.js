import { Controller } from "@hotwired/stimulus";
import Chart from "chart.js/auto";

export default class extends Controller {
  static targets = ["canvas"];
  static values = {
    startDate: String, 
    chartType: String,
    chartLabel: String,
    chartTimeUnit: String,
    chartData: Object
  };

  connect() {
    if (this.isEmpty(this.chartDataValue)) {
      this.displayNoData();
      return;
    }

    this.startDate = new Date(this.startDateValue);
    this.chartData = null;
    this.isMultiUser = this.isMultiUserData(this.chartDataValue);
    this.isChartDataCategorical = this.isCategoricalData(this.chartDataValue);
    this.chart = null;

    this.renderChart();
  }

  renderChart() {   
    if (this.isMultiUser) {
      this.chartData = this.groupDataByUser(this.chartDataValue);
    } else if (this.isChartDataCategorical) {
      this.chartData = this.groupData(this.chartDataValue);
    } else {
      this.chartData = this.filterDataByStartDate(this.chartDataValue);
    }

    const scales = {
      y: { beginAtZero: true }
    };

    if (!this.isChartDataCategorical && !this.isMultiUser) {
      scales.x = { type: "time", time: { unit: this.chartTimeUnitValue } };
    }

    const ctx = this.canvasTarget.getContext("2d");

    const datasets = this.isMultiUser ? this.chartData.datasets : [{
      label: this.chartLabelValue,
      data: this.chartData.values,
      borderWidth: 1
    }];

    this.chart = new Chart(ctx, {
      type: this.chartTypeValue,
      data: {
        labels: this.chartData.labels,
        datasets: datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: scales
      }
    });
  }

  filterDataByStartDate(data) {
    const labels = [];
    const values = [];

    if (Object.keys(data)[0].includes(" - ")) {
      for (const [dateRangeStr, value] of Object.entries(data)) {
        const eventStartDate = new Date(dateRangeStr.split(" - ")[0]);
        if (eventStartDate >= this.startDate) {
          labels.push(eventStartDate);
          values.push(value);
        }
      }
    } else {
      for (const [dateStr, value] of Object.entries(data)) {
        const date = new Date(dateStr);
        if (date >= this.startDate) {
          labels.push(date);
          values.push(value);
        }
      }
    }

    return { labels, values };
  }

  destroyChart() {
    this.chart.destroy();
  }

  toggleChartType(event) {
    this.chartTypeValue = event.target.value; 

    this.destroyChart();
    this.renderChart();
  }

  updateStartDate(event) {
    this.startDate = new Date(event.target.value);

    this.destroyChart();
    this.renderChart();
  }

  isCategoricalData(data) {
    const label = Object.keys(data)[0];

    if (this.isDateValid(label)) {
      return false;
    }

    if (label.includes(" - ") && this.isDateValid(label.split(" - ")[0])) {
      return false;
    }

    return true;
  }

  isDateValid(dateStr) {
    return !isNaN(new Date(dateStr));
  }

  groupData(data) {
    const labels = Object.keys(data);
    const values = Object.values(data).map(value => parseFloat(value));

    return { labels, values };
  }

  isEmpty(obj) {
    for (const prop in obj) {
      if (Object.hasOwn(obj, prop)) {
        return false;
      }
    }
    return true;
  }

  isMultiUserData(data) {
    const firstValue = Object.values(data)[0];
    return typeof firstValue === 'object' && !Array.isArray(firstValue) && firstValue !== null;
  }

  groupDataByUser(data) {
    const allDateRanges = new Set();

    Object.values(data).forEach(userDates => {
      Object.keys(userDates).forEach(date => allDateRanges.add(date));
    });

    const labels = Array.from(allDateRanges);
    const datasets = Object.entries(data).map(([user, dateRangeValues]) => ({
      label: user,
      data: labels.map(date => dateRangeValues[date] || null),
      borderWidth: 1
    }));

    return { labels, datasets };
  }

  displayNoData() {
    const noDataElement = document.createElement('p');
    noDataElement.classList.add('text-muted');
    noDataElement.innerText = 'No data available.';
    this.element.querySelector('.chart-container').appendChild(noDataElement);
    this.element.querySelector('canvas').style.display = 'none';
  }
}
