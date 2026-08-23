# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Interests', type: :request do
  let!(:admin) { FactoryBot.create(:user, role: 'admin') }

  before do
    login_as(admin, scope: :user)
  end

  describe 'DELETE /admin/interests/:id' do
    let!(:interest) do
      Interest.create!(
        name: 'Test User',
        email: 'TestUser@example.com'
      )
    end

    it 'deletes the interest' do
      expect do
        delete admin_interest_path(interest)
      end.to change(Interest, :count).by(-1)

      expect(URI(response.location).path).to eq(admin_interests_path)
    end
  end
end
