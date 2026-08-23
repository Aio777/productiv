import Rails from "@rails/ujs";
import "@hotwired/turbo-rails";
import "bootstrap";
import "chartkick/chart.js"
import "../scripts/manage-features-modal-content";
import "../scripts/social-media-share-buttons";
import "../scripts/register-interest-modal";
import "../scripts/manage-pricing-modal-content";
import "../scripts/new-review-modal";
import "../scripts/faq-accordion";
import "../scripts/task-select";
import "../scripts/progress-bar";

import { Application } from "@hotwired/stimulus";
import PomodoroController from "../scripts/pomodoro-controller";
import FloatingPomodoroController from "../scripts/floating-pomodoro-controller";
import ReminderToggleController from "../scripts/reminder_toggle_controller";   
import TaskFilterController from "../scripts/task_filter_controller";  
import InviteesController from "../scripts/invitees_controller";
import ImagePreviewController from "../scripts/image_preview_controller";
import RadarModalController from "../scripts/radar_modal_controller";
import AiTaskBreakdownController from "../scripts/ai-task-breakdown-controller";
import ReminderFilterController from "../scripts/reminder_filter_controller";
import ChartController from "../scripts/charts_controller/chart_controller";

Rails.start();

window.Stimulus = Application.start()
// eslint-disable-next-line
Stimulus.register("pomodoro", PomodoroController)
// eslint-disable-next-line
Stimulus.register("floating-pomodoro", FloatingPomodoroController)
// eslint-disable-next-line
Stimulus.register("reminder-toggle", ReminderToggleController)
// eslint-disable-next-line
Stimulus.register("reminder-filter", ReminderFilterController)
// eslint-disable-next-line
Stimulus.register("task-filter", TaskFilterController)
// eslint-disable-next-line
Stimulus.register("ai-task-breakdown", AiTaskBreakdownController)
// eslint-disable-next-line
Stimulus.register("invitees", InviteesController);
// eslint-disable-next-line
Stimulus.register("image-preview", ImagePreviewController);
// eslint-disable-next-line
Stimulus.register("radar-modal", RadarModalController);
// eslint-disable-next-line
Stimulus.register("chart", ChartController);
