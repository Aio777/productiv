# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Social Media Sharing', type: :feature do
  before do
    visit root_path
  end

  it 'opens Task Breakdown modal and ensures X share link has correct attributes', :js do
    card = find('.feature-card', text: 'Task Breakdown Assistance with AI')
    card.find('button', text: 'Read More').click

    expect(page).to have_selector('#featuresModal.show', visible: true)

    within '#featuresModal' do
      twitter_link = find('a', text: 'X (formerly Twitter)')

      expect(twitter_link[:href]).to include('https://twitter.com/intent/tweet')
      expect(twitter_link[:'data-shared-feature-message']).to eq("Shared Feature 'Task Breakdown Assistance with AI'")
      # data-shared-feature-message="Shared Feature 'Task Breakdown Assistance with AI'"
      expect(twitter_link[:target]).to eq('_blank')
      expect(twitter_link[:rel]).to include('noopener')
    end
  end

  it 'opens Pomodoro Timer modal and ensures Email share link has correct attributes', :js do
    card = find('.feature-card', text: 'Pomodoro Timer')
    card.find('button', text: 'Read More').click

    expect(page).to have_css('#featuresModal.show', visible: true, wait: 5)

    within '#featuresModal' do
      email_link = find('a', text: 'Email')

      expect(email_link[:href]).to include('https://mail.google.com/mail/')
      expect(email_link[:'data-shared-feature-message']).to eq("Shared Feature 'Pomodoro Timer'")
      expect(email_link[:target]).to eq('_blank')
      expect(email_link[:rel]).to include('noopener')
    end
  end

  it 'opens Virtual Plant modal and ensures WhatsApp share link has correct attributes', :js do
    card = find('.feature-card', text: 'Your Virtual Plant')
    card.find('button', text: 'Read More').click

    expect(page).to have_css('#featuresModal.show', visible: true, wait: 5)

    within '#featuresModal' do
      whatsapp_link = find('a', text: 'WhatsApp (Web)')

      expect(whatsapp_link[:href]).to include('https://wa.me/')
      expect(whatsapp_link[:'data-shared-feature-message']).to eq("Shared Feature 'Your Virtual Plant'")
      expect(whatsapp_link[:target]).to eq('_blank')
      expect(whatsapp_link[:rel]).to include('noopener')
    end
  end

  it 'opens Leaderboards modal and ensures Reddit share link has correct attributes', :js do
    card = find('.feature-card', text: 'Leaderboards')
    card.find('button', text: 'Read More').click

    expect(page).to have_css('#featuresModal.show', visible: true, wait: 5)

    within '#featuresModal' do
      reddit_link = find('a', text: 'Reddit')

      expect(reddit_link[:href]).to include('https://www.reddit.com/')
      expect(reddit_link[:'data-shared-feature-message']).to eq("Shared Feature 'Leaderboards'")
      expect(reddit_link[:target]).to eq('_blank')
      expect(reddit_link[:rel]).to include('noopener')
    end
  end
end
