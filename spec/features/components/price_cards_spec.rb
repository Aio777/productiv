# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Price Cards', type: :feature do
  describe 'Free Subscription Card' do
    it 'shows the Free Subscription card on the landing page' do
      visit root_path

      within('.content-card') do
        expect(page).to have_content('Free Plan')
      end
    end

    it 'opens the Free Plan modal and shows the correct text', :js do
      visit root_path

      card = find('.feature-card', text: 'Free Plan')
      within(card) do
        click_on 'Read More'
      end

      modal = find('#pricingModal', visible: true)

      expect(modal).to have_content('Essential tools for students trying to keep the important tasks')
      expect(modal).to have_selector('div.modal-body', text: 'Limited AI Task Breakdown Requests')
    end
  end

  describe 'Monthly Subscription Card' do
    it 'shows the Monthly Subscription card on the landing page' do
      visit root_path

      within('.content-card') do
        expect(page).to have_content('Monthly Plan')
      end
    end

    it 'opens the Read More modal when the Read More button associated with the Monthly Subscription card is clicked',
       :js do
      visit root_path

      card = find('.feature-card', text: 'Monthly Plan')
      within(card) do
        click_on 'Read More'
      end

      modal = find('#pricingModal', visible: true)

      expect(modal).to have_content('Perfect for students or teams who want unlimited organisational')
    end
  end

  describe 'Annual Subscription Card' do
    it 'shows the Annual Subscription card on the landing page' do
      visit root_path

      within('.content-card') do
        expect(page).to have_content('Annual Plan')
      end
    end
  end
end
