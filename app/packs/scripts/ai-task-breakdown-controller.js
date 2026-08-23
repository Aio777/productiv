import { Controller } from "@hotwired/stimulus";
import { Modal } from "bootstrap";

export default class extends Controller {
  static targets = ["name", "description", "content", "saveButton"];
  static values = { endpoint: String, fallbackEndpoint: String };

  async open(event) {
    event.preventDefault();

    const taskName = this.nameTarget.value.trim();
    const userId = this.nameTarget.dataset.userId;
    const taskType = this.nameTarget.dataset.taskType;
    const description = this.hasDescriptionTarget ? this.descriptionTarget.value.trim() : "";

    this.ensureModal();

    this.contentTarget.innerHTML = "Generating task breakdown...";
    this.updateSaveButton();
    this.modal.show();

    if (!taskName) {
      this.contentTarget.innerHTML = '<div class="text-danger">Please enter a task name first.</div>';
      this.updateSaveButton();
      return;
    }

    try {
      const response = await fetch(this.endpointValue, {
        method: "POST",
        headers: this.headers(),
        body: JSON.stringify({
          task_name: taskName,
          description: description,
          user_id: userId,
          task_type: taskType
        })
      });

      let data;

      try {
        data = await response.json();
      } catch (jsonError) {
        throw new Error("Invalid JSON response", { cause: jsonError });
      }

      if (!response.ok) {
        throw new Error(data.error || `Request failed (${response.status})`);
      }

      this.contentTarget.innerHTML = this.format(data.breakdown || "(no breakdown returned)");
      this.updateSaveButton();
    } catch (error) {
      console.error(error);

      try {
        if (!this.hasFallbackEndpointValue) {
          throw new Error("Fallback endpoint is not configured", { cause: error });
        }

        const response = await fetch(this.fallbackEndpointValue, {
          method: "POST",
          headers: this.headers(),
          body: JSON.stringify({
            task_name: taskName,
            description: description,
            user_id: userId,
            task_type: taskType
          })
        });

        let fallbackData;

        try {
          fallbackData = await response.json();
        } catch (jsonError) {
          throw new Error("Invalid fallback JSON response", { cause: jsonError });
        }

        if (!response.ok) {
          throw new Error(
            fallbackData.error || `Fallback request failed (${response.status})`,
            { cause: error }
          );
        }

        this.contentTarget.innerHTML = this.format(fallbackData.breakdown || "(no breakdown returned)");
        this.updateSaveButton();
      } catch (fallbackError) {
        console.error(fallbackError);
        this.contentTarget.innerHTML = '<div class="text-danger">Failed to generate breakdown.</div>';
        this.updateSaveButton();
      }
    }
  }

  addToTaskDescription() {
    if (!this.hasContentTarget || !this.hasDescriptionTarget) return;

    const aiContent = this.contentTarget.innerText.trim();

    if (this.invalidContent(aiContent)) return;

    this.descriptionTarget.value = aiContent;

    this.descriptionTarget.dispatchEvent(new Event("input", { bubbles: true }));
    this.descriptionTarget.dispatchEvent(new Event("change", { bubbles: true }));

    this.hideModal();
  }

  updateSaveButton() {
    if (!this.hasContentTarget || !this.hasSaveButtonTarget) return;

    const content = this.contentTarget.innerText.trim();

    this.saveButtonTarget.disabled = this.invalidContent(content);
  }

  invalidContent(content) {
    const disabledMessages = [
      "",
      "Generating task breakdown...",
      "Generating breakdown...",
      "Failed to generate breakdown.",
      "Please enter a task name first.",
      "(no breakdown returned)"
    ];

    return disabledMessages.includes(content);
  }

  ensureModal() {
    if (this.modal) return;

    const modalElement = this.element.querySelector(".ai-breakdown-modal");
    this.modal = new Modal(modalElement);
  }

  hideModal() {
    if (this.modal) {
      this.modal.hide();
    }
  }

  format(text) {
    return this.escape(text).replace(/\n/g, "<br>");
  }

  escape(str) {
    return String(str).replace(/[&<>"']/g, (m) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#039;"
    }[m]));
  }

  headers() {
    const headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    const token = document.querySelector('meta[name="csrf-token"]')?.content;

    if (token) {
      headers["X-CSRF-Token"] = token;
    }

    return headers;
  }
}