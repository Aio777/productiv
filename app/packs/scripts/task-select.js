window.handleTaskSelect = function(event) {
  document.querySelectorAll(".task-row").forEach(row => {
    row.classList.remove("selected")
  })

  event.currentTarget.classList.add("selected")

  sessionStorage.setItem("taskSelectedManually", "true")
}
