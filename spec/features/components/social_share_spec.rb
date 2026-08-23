# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Social Media Sharing', type: :feature do
  let(:share_message) { 'Check out Productiv - the ultimate student productivity app!' }
  let(:demo_site_url) { SocialMediaHelper::DEMO_SITE_URL }

  before do
    visit root_path
  end

  describe 'X (formerly Twitter) share button' do
    it 'opens Twitter share URL in a new tab' do
      twitter_link = find('a[data-social-media-share-button]', text: /X/i)

      expect(twitter_link[:href]).to include('https://twitter.com/intent/tweet')
      expect(twitter_link[:href]).to include(CGI.escape(share_message))
      expect(twitter_link[:target]).to eq('_blank')
      expect(twitter_link[:rel]).to include('noopener')
    end
  end

  describe 'WhatsApp share button' do
    it 'opens WhatsApp share URL in a new tab' do
      whatsapp_link = find('a[data-social-media-share-button]', text: /WhatsApp/i)

      expect(whatsapp_link[:href]).to include('https://wa.me/?text=')
      expect(whatsapp_link[:href]).to include(CGI.escape(share_message))
      expect(whatsapp_link[:href]).to include(CGI.escape(demo_site_url))
      expect(whatsapp_link[:target]).to eq('_blank')
      expect(whatsapp_link[:rel]).to include('noopener')
      expect(whatsapp_link).to have_css('i.bi-whatsapp')
    end
  end

  describe 'Reddit share button' do
    it 'opens Reddit share URL in a new tab' do
      reddit_link = find('a[data-social-media-share-button]', text: /Reddit/i)

      expect(reddit_link[:href]).to include('https://www.reddit.com/submit')
      expect(reddit_link[:href]).to include(CGI.escape(demo_site_url))
      expect(reddit_link[:target]).to eq('_blank')
      expect(reddit_link[:rel]).to include('noopener')
      expect(reddit_link).to have_css('i.bi-reddit')
    end
  end

  describe 'Email share button' do
    it 'opens Gmail compose URL in a new tab' do
      email_link = find('a[data-social-media-share-button]', text: /Email/i)

      expect(email_link[:href]).to include('https://mail.google.com/mail/?view=cm')
      expect(email_link[:href]).to include(CGI.escape(share_message))
      expect(email_link[:href]).to include(CGI.escape(demo_site_url))
      expect(email_link[:target]).to eq('_blank')
      expect(email_link[:rel]).to include('noopener')
      expect(email_link).to have_css('i.bi-envelope')
    end
  end
end
