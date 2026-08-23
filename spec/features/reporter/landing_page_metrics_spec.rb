# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Landing Page Metrics', :js, type: :feature do
  let(:reporter) { FactoryBot.create(:user, role: 'reporter') }

  it 'shows the correct Bounce Rate' do
    visit root_path
    reset_session!

    visit root_path
    reset_session!

    visit root_path
    click_on 'Leave a Review'
    reset_session!

    login_as reporter, scope: :user
    visit reporter_landing_page_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#bounce-rate')['data-chart-chart-data-value']
      expect(chart_data).to have_content({ 'Bounce Rate' => '66.67%' }.to_json, exact: true)
    end
  end

  it 'shows the correct Traffic Media' do
    visit root_path(utm_medium: 'Flyer')
    reset_session!

    visit root_path(utm_medium: 'Sponsorship')
    reset_session!
    visit root_path(utm_medium: 'Sponsorship')
    reset_session!
    visit root_path(utm_medium: 'Sponsorship')
    reset_session!

    visit root_path(utm_medium: 'Social Media')
    reset_session!
    visit root_path(utm_medium: 'Social Media')
    reset_session!

    login_as reporter, scope: :user
    visit reporter_landing_page_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#traffic-media')['data-chart-chart-data-value']
      expect(chart_data).to have_content(
        { 'Sponsorship' => '50.0%', 'Social Media' => '33.33%', 'Flyer' => '16.67%' }.to_json, exact: true
      )
    end
  end

  it 'shows the correct Traffic Sources' do
    visit root_path(utm_source: 'The Diamond - Study Rooms')
    reset_session!

    visit root_path(utm_source: 'Instagram')
    reset_session!
    visit root_path(utm_source: 'Instagram')
    reset_session!

    visit root_path(utm_source: 'TikTok')
    reset_session!
    visit root_path(utm_source: 'TikTok')
    reset_session!
    visit root_path(utm_source: 'TikTok')
    reset_session!
    visit root_path(utm_source: 'TikTok')
    reset_session!

    login_as reporter, scope: :user
    visit reporter_landing_page_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#traffic-sources')['data-chart-chart-data-value']
      expect(chart_data).to have_content(
        { 'TikTok' => '57.14%', 'Instagram' => '28.57%', 'The Diamond - Study Rooms' => '14.29%' }.to_json, exact: true
      )
    end
  end
end
