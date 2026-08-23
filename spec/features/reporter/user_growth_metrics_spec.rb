# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Growth Metrics', :js, type: :feature do
  let(:subscribers) { FactoryBot.create_list(:user, 6, role: 'subscriber') }

  before do
    reporter = FactoryBot.create(:user, role: 'reporter')

    travel_to Time.zone.local(2026, 1, 5, 9, 0, 0)
    freeze_time

    visit new_user_session_path
    page.execute_script(<<~JS)
      document.querySelector('input[type="email"]').value = "#{subscribers[0].email}";
      document.querySelector('input[type="password"]').value = "#{subscribers[0].password}";
      document.querySelector('input[type="submit"]').click();
    JS
    logout

    travel 1.hour do
      visit new_user_session_path
      page.execute_script(<<~JS)
        document.querySelector('input[type="email"]').value = "#{subscribers[1].email}";
        document.querySelector('input[type="password"]').value = "#{subscribers[1].password}";
        document.querySelector('input[type="submit"]').click();
      JS
      logout
    end

    travel 1.day do
      visit new_user_session_path
      page.execute_script(<<~JS)
        document.querySelector('input[type="email"]').value = "#{subscribers[2].email}";
        document.querySelector('input[type="password"]').value = "#{subscribers[2].password}";
        document.querySelector('input[type="submit"]').click();
      JS
      logout
    end

    travel 1.week do
      visit new_user_session_path
      page.execute_script(<<~JS)
        document.querySelector('input[type="email"]').value = "#{subscribers[3].email}";
        document.querySelector('input[type="password"]').value = "#{subscribers[3].password}";
        document.querySelector('input[type="submit"]').click();
      JS
      logout
    end

    travel 1.week + 3.days do
      visit new_user_session_path
      page.execute_script(<<~JS)
        document.querySelector('input[type="email"]').value = "#{subscribers[4].email}";
        document.querySelector('input[type="password"]').value = "#{subscribers[4].password}";
        document.querySelector('input[type="submit"]').click();
      JS
      logout
    end

    travel 1.month do
      visit new_user_session_path
      page.execute_script(<<~JS)
        document.querySelector('input[type="email"]').value = "#{subscribers[5].email}";
        document.querySelector('input[type="password"]').value = "#{subscribers[5].password}";
        document.querySelector('input[type="submit"]').click();
      JS
      logout
    end

    login_as reporter, scope: :user
    visit reporter_user_growth_metrics_path
  end

  it 'shows the correct active users by day' do
    within(:css, '.row.g-4') do
      chart_data = find('#active-users-by-day')['data-chart-chart-data-value']
      expect(chart_data).to have_content(
        {
          '5 January 2026' => 2,
          '6 January 2026' => 1,
          '12 January 2026' => 1,
          '15 January 2026' => 1,
          '5 February 2026' => 1
        }.to_json,
        exact: true
      )
    end
  end

  it 'shows the correct active users by week' do
    within(:css, '.row.g-4') do
      chart_data = find('#active-users-by-week')['data-chart-chart-data-value']
      expect(chart_data).to have_content(
        { '5 Jan 2026 - 11 Jan 2026' => 3, '12 Jan 2026 - 18 Jan 2026' => 2, '2 Feb 2026 - 8 Feb 2026' => 1 }.to_json,
        exact: true
      )
    end
  end

  it 'shows the correct active users by month' do
    within(:css, '.row.g-4') do
      chart_data = find('#active-users-by-month')['data-chart-chart-data-value']
      expect(chart_data).to have_content({ 'January 2026' => 5, 'February 2026' => 1 }.to_json, exact: true)
    end
  end
end
