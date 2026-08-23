# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscriber AI Task Breakdown', type: :request do
  let!(:subscriber) { create(:user, role: 'subscriber') }
  let(:demo_task_description) do
    'This is a pre-seeded demo task used to show the AI task breakdown ' \
      'feature when the external AI service is unavailable.'
  end

  before do
    login_as(subscriber, scope: :user)
  end

  describe 'POST /subscriber/ai_taskbreakdown/generate' do
    it 'returns a breakdown when the AI service succeeds' do
      allow(Ai::GeminiClient).to receive(:generate_text).and_return(
        "1. Draft outline\n2. Write intro\n3. Review work"
      )

      post subscriber_ai_taskbreakdown_generate_path,
           params: {
             task_name: 'Write essay',
             description: 'Draft and submit coursework'
           },
           as: :json

      expect(response).to have_http_status(:ok)

      parsed = JSON.parse(response.body)
      expect(parsed['breakdown']).to include('Draft outline')
      expect(parsed['breakdown']).to include('Write intro')
      expect(parsed['breakdown']).to include('Review work')
    end

    it 'returns an error and reports to Sentry when the AI service fails' do
      error = Ai::GeminiClient::Error.new('API unavailable')

      allow(Sentry).to receive(:capture_exception)
      allow(Ai::GeminiClient).to receive(:generate_text).and_raise(error)

      post subscriber_ai_taskbreakdown_generate_path,
           params: {
             task_name: 'Write essay',
             description: 'Draft and submit coursework'
           },
           as: :json

      expect(response).to have_http_status(:bad_gateway)
      expect(Sentry).to have_received(:capture_exception).with(error)

      parsed = JSON.parse(response.body)
      expect(parsed['error']).to include('API unavailable')
    end

    it 'returns an unexpected error and reports to Sentry for non-Gemini failures' do
      error = StandardError.new('Unexpected boom')

      allow(Sentry).to receive(:capture_exception)
      allow(Ai::GeminiClient).to receive(:generate_text).and_raise(error)

      post subscriber_ai_taskbreakdown_generate_path,
           params: {
             task_name: 'Write essay',
             description: 'Draft and submit coursework'
           },
           as: :json

      expect(response).to have_http_status(:internal_server_error)
      expect(Sentry).to have_received(:capture_exception).with(error)

      parsed = JSON.parse(response.body)
      expect(parsed['error']).to eq('Unexpected error')
    end

    it 'returns bad request when task name is missing' do
      post subscriber_ai_taskbreakdown_generate_path,
           params: {
             task_name: '',
             description: 'Draft and submit coursework'
           },
           as: :json

      expect(response).to have_http_status(:bad_request)

      parsed = JSON.parse(response.body)
      expect(parsed['error']).to eq('task_name is required')
    end
  end

  describe 'POST /subscriber/ai_taskbreakdown/fallback' do
    it 'returns a fallback breakdown for the exact demo task' do
      post subscriber_ai_taskbreakdown_fallback_path,
           params: {
             task_name: 'Demo AI Task',
             description: demo_task_description
           },
           as: :json

      expect(response).to have_http_status(:ok)

      parsed = JSON.parse(response.body)
      expect(parsed['fallback']).to be true
      expect(parsed['breakdown']).to include('DEMO FALLBACK RESPONSE')
      expect(parsed['breakdown']).to include('pre-written example breakdown')
      expect(parsed['breakdown']).to include('Review the task description')
      expect(parsed['breakdown']).to include('Use a focused work session')
    end

    it 'does not return fallback output when the description does not match' do
      post subscriber_ai_taskbreakdown_fallback_path,
           params: {
             task_name: 'Demo AI Task',
             description: 'Different description'
           },
           as: :json

      expect(response).to have_http_status(:not_found)

      parsed = JSON.parse(response.body)
      expect(parsed['error']).to eq('No fallback breakdown available')
    end
  end
end
