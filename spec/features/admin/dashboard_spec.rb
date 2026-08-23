# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Dashboard', type: :feature do
  describe 'visits dashboard' do
    it 'admin can visit admin dashboard' do
      admin = FactoryBot.create(:user, role: 'admin')
      login_as admin, scope: :user
      visit admin_root_path
      expect(page).to have_current_path(admin_root_path)
      expect(page).to have_content('Logout')
    end

    it 'displays recent added FAQs' do
      admin = FactoryBot.create(:user, role: 'admin')
      post1 = FactoryBot.create(:post, created_at: 2.days.ago)
      post2 = FactoryBot.create(:post, created_at: 1.day.ago)
      post3 = FactoryBot.create(:post, created_at: 3.days.ago)
      login_as admin, scope: :user
      visit admin_root_path
      expect(page).to have_content(post2.title)
      expect(page).to have_content(post1.title)
      expect(page).to have_content(post3.title)
    end

    it 'displays recent added Reviews' do
      admin = FactoryBot.create(:user, role: 'admin')
      review1 = FactoryBot.create(:review, created_at: 2.days.ago)
      review2 = FactoryBot.create(:review, created_at: 1.day.ago)
      review3 = FactoryBot.create(:review, created_at: 3.days.ago)
      login_as admin, scope: :user
      visit admin_root_path
      expect(page).to have_content(review1.name)
      expect(page).to have_content(review2.name)
      expect(page).to have_content(review3.name)
      expect(page).to have_content(review1.rating)
      expect(page).to have_content(review2.rating)
      expect(page).to have_content(review3.rating)
    end

    it 'displays currently selected reviews' do
      admin = FactoryBot.create(:user, role: 'admin')
      Review.find_by(review_index: 1)&.update(review_index: nil)
      review1 = FactoryBot.create(:review, name: 'Review One', review_index: 1)
      login_as admin, scope: :user
      visit admin_root_path
      expect(page).to have_content(review1.name)
    end
  end
end
