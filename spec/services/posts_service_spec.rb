# spec/services/posts_service_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostsService, type: :service do
  describe '.update_question_interests' do
    it 'correctly updates the interest count for the given questions' do
      questions = FactoryBot.create_list(:post, 5)
      FactoryBot.create_list(:ahoy_event, 3, name: "#{
        Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_QUESTION_PREFIX]
      } '#{questions[0].title}'", properties: { post_id: questions[0].id })

      FactoryBot.create_list(:ahoy_event, 2, name: "#{
        Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_QUESTION_PREFIX]
      } '#{questions[1].title}'", properties: { post_id: questions[1].id })

      FactoryBot.create_list(:ahoy_event, 5, name: "#{
        Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_QUESTION_PREFIX]
      } '#{questions[2].title}'", properties: { post_id: questions[2].id })

      FactoryBot.create_list(:ahoy_event, 7, name: "#{
        Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_QUESTION_PREFIX]
      } '#{questions[4].title}'", properties: { post_id: questions[4].id })

      described_class.update_question_interests(questions)
      expect(questions.pluck(:id, :interest_count).to_h).to eq(
        { questions[0].id => 3, questions[1].id => 2, questions[2].id => 5, questions[3].id => 0, questions[4].id => 7 }
      )
    end
  end
end
