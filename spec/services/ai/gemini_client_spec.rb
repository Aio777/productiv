# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::GeminiClient do
  around do |example|
    original_api_key = ENV['GEMINI_API_KEY']
    original_model = ENV['GEMINI_MODEL']

    ENV['GEMINI_API_KEY'] = 'test-api-key'
    ENV['GEMINI_MODEL'] = 'gemini-2.5-flash'

    example.run
  ensure
    ENV['GEMINI_API_KEY'] = original_api_key
    ENV['GEMINI_MODEL'] = original_model
  end

  it 'returns text from a stubbed Gemini response' do
    http = instance_double(Net::HTTP)
    response = instance_double(
      Net::HTTPOK,
      code: '200',
      body: {
        candidates: [
          {
            content: {
              parts: [
                { text: "1. Draft outline\n2. Write intro\n3. Review work" }
              ]
            }
          }
        ]
      }.to_json
    )

    allow(Net::HTTP).to receive(:new).and_return(http)
    allow(http).to receive(:use_ssl=)
    allow(http).to receive(:read_timeout=)
    allow(http).to receive(:request).and_return(response)

    result = described_class.generate_text('Write essay')

    expect(result).to include('Draft outline')
  end
end
