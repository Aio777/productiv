# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin users index performance', type: :feature do
  let!(:admin) do
    FactoryBot.create(
      :user,
      role: 'admin',
      first_name: 'Performance',
      last_name: 'Admin'
    )
  end

  before do
    seed_subscribers

    login_as(admin, scope: :user)
  end

  it 'loads the paginated users index with a large subscriber list in an acceptable time' do
    expect do
      visit admin_users_path(role: 'subscriber')

      expect(page).to have_content('Users')
      expect(page).to have_select('role-filter', selected: 'Subscribers')
      expect(page.text).to match(/Subscriber Page 1 of \d+/)
      expect(page).to have_content('Performance User 0001')
      expect(page).to have_content('performance.user.0001@example.com')
      expect(page).to have_content('Performance User 0010')
      expect(page).to have_link('Next')
      expect(page).to have_link('New User')
    end.to perform_under(1500).ms
  end

  def seed_subscribers
    current_time = Time.current

    User.insert_all(
      1_000.times.map do |index|
        user_number = index + 1
        padded_number = user_number.to_s.rjust(4, '0')

        {
          first_name: "Performance User #{padded_number}",
          last_name: "Loadtest #{padded_number}",
          email: "performance.user.#{padded_number}@example.com",
          role: 'subscriber',
          encrypted_password: '',
          points: 0,
          layout: 15,
          was_subscriber: true,
          created_at: current_time,
          updated_at: current_time
        }
      end
    )
  end
end
