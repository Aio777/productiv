# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin manages reviews', type: :feature do
  let!(:admin) { create(:user, role: 'admin') }
  let!(:review) { create(:review, body: 'Great service!', rating: 5) }

  before do
    login_as(admin, scope: :user)
  end

  it 'displays no reviews when no reviews selected' do
    Review.find_by(review_index: 1)&.update(review_index: nil)
    Review.find_by(review_index: 2)&.update(review_index: nil)
    Review.find_by(review_index: 3)&.update(review_index: nil)

    visit admin_reviews_path
    expect(page).to have_current_path(admin_reviews_path)
    expect(page).to have_content('No current review')
  end

  it 'updates currently selected reviews' do
    Review.find_by(review_index: 1)&.update(review_index: nil)
    FactoryBot.create(:review, name: 'Review One', review_index: 1)
    review2 = FactoryBot.create(:review, name: 'Review Two', review_index: nil)

    visit admin_reviews_path
    within(:xpath, "//div[.//label[text()='First Review Shown']]") do
      select 'Review Two'
    end
    within(:xpath, "//div[.//label[text()='Second Review Shown']]") do
      select 'Review One'
    end
    expect(page).to have_current_path(admin_reviews_path)
    visit root_path
    expect(page).to have_content(review2.name)
  end

  it 'views review list' do
    visit admin_reviews_path

    expect(page).to have_current_path(admin_reviews_path)
    expect(page).to have_text('Reviews')
    expect(page).to have_text('Great service!')
    expect(page).to have_text('5')
  end

  it 'deletes a review' do
    visit admin_reviews_path

    within(:xpath, "//tr[td[contains(text(), '#{review.body}')]]") do
      click_on 'Destroy'
    end

    expect(page).to have_current_path(admin_reviews_path, ignore_query: true)
    expect(page).not_to have_text('Great service!')
  end

  it 'when non user creates review then review shows in list page' do
    FactoryBot.create(:post, created_at: 2.days.ago, interest_count: 5)
    visit root_path
    click_button 'Leave a Review'
    fill_in 'Your name', with: 'Test User'
    fill_in 'Rating', with: '5'
    fill_in 'Your review', with: 'This is a test review.'
    click_button 'Submit Review'
    admin = FactoryBot.create(:user, role: 'admin')
    login_as admin, scope: :user
    visit admin_reviews_path
    expect(page).to have_content('Test User')
    expect(page).to have_content('This is a test review.')
  end
end
