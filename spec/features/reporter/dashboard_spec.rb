# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reporter Dashboard', :js, type: :feature do
  let(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', points: 100) }
  let(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', points: 100) }
  let(:reporter) { FactoryBot.create(:user, role: 'reporter') }

  describe 'visiting the Dashboard' do
    it 'Reporter can only visit the Reporter Dashboard' do
      login_as reporter, scope: :user

      visit reporter_root_path
      expect(page).to have_current_path(reporter_root_path)

      visit subscriber_root_path
      expect(page).to have_current_path(root_path)

      visit admin_root_path
      expect(page).to have_current_path(root_path)
    end
  end
end
