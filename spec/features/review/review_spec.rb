# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin can view changes in review interests', type: :feature do
  let!(:admin) { create(:user, role: 'admin') }
  let!(:review) do
    create(:review, body: 'Great service!', rating: 4, positive_interest_count: 1, negative_interest_count: 0)
  end
  let!(:user) { create(:user) }

  it 'increases interest count when thumbs up is clicked' do
    login_as(user, scope: :user)
    visit root_path

    within(:xpath, "//li[contains(@class, 'p-4') and .//p[contains(text(), '#{review.body}')]]") do
      click_button '👍'
    end

    logout(:user)

    login_as(admin, scope: :user)
    visit admin_reviews_path

    within(:xpath, "//tr[td[contains(text(), '#{review.body}')]]") do
      expect(page).to have_content('2')
    end
  end

  it 'decreases interest count when thumbs down is clicked' do
    login_as(user, scope: :user)
    visit root_path

    within(:xpath, "//li[contains(@class, 'p-4') and .//p[contains(text(), '#{review.body}')]]") do
      click_button '👎'
    end

    logout(:user)

    login_as(admin, scope: :user)
    visit admin_reviews_path

    within(:xpath, "//tr[td[contains(text(), '#{review.body}')]]") do
      expect(page).to have_content('0')
    end
  end

  it 'A review cannot be rated multiple times as a user' do
    login_as(user, scope: :user)
    visit root_path

    within(:xpath, "//li[contains(@class, 'p-4') and .//p[contains(text(), '#{review.body}')]]") do
      click_button '👍'
    end

    within(:xpath, "//li[contains(@class, 'p-4') and .//p[contains(text(), '#{review.body}')]]") do
      expect { click_button '👍' }.to raise_error(Capybara::ElementNotFound)
    end

    logout(:user)

    login_as(admin, scope: :user)
    visit admin_reviews_path

    within(:xpath, "//tr[td[contains(text(), '#{review.body}')]]") do
      expect(page).to have_content('2')
    end
  end

  it 'A review correctly displays its rating in stars' do
    login_as(user, scope: :user)
    visit root_path

    expect(page).to have_content('★ ★ ★ ★')
  end

  it 'A destroyed review does not appear on the homepage' do
    login_as(user, scope: :user)

    visit root_path
    expect(page).to have_content('Great service!')

    review.destroy

    visit root_path
    expect(page).not_to have_content('Great service!')
  end
end
