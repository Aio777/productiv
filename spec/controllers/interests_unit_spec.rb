# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Interests', type: :request do
  describe 'POST /interests' do
    it 'creates a new interest' do
      expect do
        post interests_path, params: {
          interest: {
            name: 'Test User',
            email: 'TestUser@example.com'
          }
        }
      end.to change(Interest, :count).by(1)

      expect(response).to redirect_to(root_path)
    end

    it 'rejects invalid interest data' do
      expect do
        post interests_path, params: {
          interest: {
            name: nil,
            email: 'TestUser@example.com'
          }
        }
      end.not_to change(Interest, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
