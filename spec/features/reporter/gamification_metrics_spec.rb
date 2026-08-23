# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Gamification Metrics', :js, type: :feature do
  let(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', points: 100) }
  let(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', points: 100) }
  let(:reporter) { FactoryBot.create(:user, role: 'reporter') }

  before do
    Rails.application.load_tasks unless Rake::Task.task_defined?('plants:check_plant_decay')
    travel_to Time.zone.local(2026, 1, 5, 9, 0, 0)
    freeze_time

    login_as subscriber1, scope: :user
    visit subscriber_root_path
  end

  it 'shows the correct number of shop purchases' do
    FactoryBot.create(:plant_item)

    visit subscriber_items_path
    first(:css, 'a[data-turbo-frame="item_preview"]').click
    click_on 'Purchase'
    logout

    login_as reporter, scope: :user
    visit reporter_gamification_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#shop-purchases-by-week')['data-chart-chart-data-value']
      expect(chart_data).to have_content({ '5 Jan 2026 - 11 Jan 2026' => 1 }.to_json, exact: true)
    end
  end

  it 'shows the correct user points per week' do
    FactoryBot.create_list(:individual_task, 3, individual_project: subscriber1.individual_project)

    visit subscriber_project_path

    all('.task-items a').first.click
    expect(page).to have_button('Complete Task')

    page.accept_confirm do
      click_on 'Complete Task'
    end
    expect(page).to have_content('Task marked as complete.')

    travel 1.week do
      all('.task-items a').first.click
      expect(page).to have_button('Complete Task')

      page.accept_confirm do
        click_on 'Complete Task'
      end
      expect(page).to have_content('Task marked as complete.')
    end

    travel 1.month do
      all('.task-items a').first.click
      expect(page).to have_button('Complete Task')

      page.accept_confirm do
        click_on 'Complete Task'
      end
      expect(page).to have_content('Task marked as complete.')
    end
    logout

    FactoryBot.create_list(:individual_task, 2, individual_project: subscriber2.individual_project, points: 6)
    login_as subscriber2, scope: :user

    visit subscriber_project_path

    all('.task-items a').first.click
    expect(page).to have_button('Complete Task')

    page.accept_confirm do
      click_on 'Complete Task'
    end
    expect(page).to have_content('Task marked as complete.')

    travel 2.days do
      all('.task-items a').first.click
      expect(page).to have_button('Complete Task')

      page.accept_confirm do
        click_on 'Complete Task'
      end
      expect(page).to have_content('Task marked as complete.')
    end
    logout

    login_as reporter, scope: :user
    visit reporter_gamification_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#points-earned-per-user-by-week')['data-chart-chart-data-value']
      expect(chart_data).to have_content({
        subscriber1.email => {
          '5 Jan 2026 - 11 Jan 2026' => 10,
          '12 Jan 2026 - 18 Jan 2026' => 10,
          '2 Feb 2026 - 8 Feb 2026' => 10
        },
        subscriber2.email => { '5 Jan 2026 - 11 Jan 2026' => 12 }
      }.to_json, exact: true)
    end
  end

  it 'shows the correct number of plant deaths' do
    expect(page).to have_button('Water')

    page.accept_confirm do
      click_on 'Water'
    end

    expect(page).to have_content('Plant has been successfully watered!')
    logout

    travel 2.weeks
    Rake::Task['plants:check_plant_decay'].invoke

    login_as reporter, scope: :user
    visit reporter_gamification_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#plant-deaths-by-week')['data-chart-chart-data-value']
      expect(chart_data).to have_content({ '19 Jan 2026 - 25 Jan 2026' => 1 }.to_json, exact: true)
    end
  end

  it 'shows the correct average plant streak' do
    page.accept_confirm do
      click_on 'Water'
    end
    expect(page).to have_content('Plant has been successfully watered!')
    logout

    travel 5.days
    login_as subscriber2, scope: :user

    visit subscriber_root_path
    page.accept_confirm do
      click_on 'Water'
    end

    expect(page).to have_content('Plant has been successfully watered!')

    logout

    travel 13.days
    Rake::Task['plants:check_plant_decay'].invoke

    login_as reporter, scope: :user
    visit reporter_gamification_metrics_path

    within(:css, '#average-plant-streak-time td') do
      expect(page).to have_content(
        ActiveSupport::Duration.build(15.5.days).inspect, exact: true
      )
    end
  end
end
