# frozen_string_literal: true

class PostsService
  def self.update_question_interests(questions)
    questions.each do |question|
      interest = Ahoy::Event.where('name LIKE ?', "#{
        Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_QUESTION_PREFIX]
      }%").where("properties->>'post_id' = ?", question.id.to_s).count

      unless question.interest_count == interest
        question.interest_count = interest
        question.save!
      end
    end
  end
end
