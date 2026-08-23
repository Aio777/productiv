# frozen_string_literal: true

class RegistrationJourneyService
  def self.register_interest_events_timeline(email)
    pre_register_interest_events = get_events_before_registering_interest(email)
    events_timeline = Array.new(pre_register_interest_events.length)

    pre_register_interest_events.each_with_index do |event, index|
      events_timeline[index] = if index != pre_register_interest_events.length - 1
                                 [event.name, event.time, pre_register_interest_events[index + 1].time]
                               else
                                 events_timeline[index] = [event.name, event.time, event.time + 5.seconds]
                               end
    end
    events_timeline
  end

  def self.get_events_before_registering_interest(registered_user_email)
    register_interest_event = Ahoy::Event.find_by!("properties->>'registration_email' = ?", registered_user_email)
    registered_user_visit = Ahoy::Visit.find(register_interest_event.visit_id)
    Ahoy::Event.where(visit_id: registered_user_visit.id).where('time <= ?', register_interest_event.time).order(:time)
  end

  private_class_method :get_events_before_registering_interest
end
