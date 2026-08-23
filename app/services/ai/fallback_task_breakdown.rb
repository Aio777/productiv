# frozen_string_literal: true

class Ai::FallbackTaskBreakdown
  DEMO_TASK_NAME = 'demo ai task'
  DEMO_DESCRIPTION_PHRASE = 'pre-seeded demo task'

  DEMO_BREAKDOWN = [
    '[DEMO FALLBACK RESPONSE - external AI was unavailable]',
    'This is a pre-written example breakdown for the seeded demo task.',
    '',
    '1. Review the task description and identify the main goal.',
    '2. Break the goal into smaller actions that can be completed one at a time.',
    '3. Decide which action should be completed first based on urgency and importance.',
    '4. Set a realistic time estimate for each action.',
    '5. Use a focused work session, such as Pomodoro, to complete the first action.',
    '6. Review progress and update the task notes before moving on.'
  ].join("\n")

  def self.for(task_name:, description:)
    return DEMO_BREAKDOWN if matches_demo_task?(task_name, description)

    nil
  end

  def self.matches_demo_task?(task_name, description)
    normalise(task_name) == DEMO_TASK_NAME &&
      normalise(description).include?(DEMO_DESCRIPTION_PHRASE)
  end
  private_class_method :matches_demo_task?

  def self.normalise(value)
    value.to_s.squish.downcase
  end
  private_class_method :normalise
end
