# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feature Engagement Metrics', :js, type: :feature do
  let(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', points: 100) }
  let(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', points: 100) }
  let(:reporter) { FactoryBot.create(:user, role: 'reporter') }

  before do
    travel_to Time.zone.local(2026, 1, 5, 9, 0, 0)
    freeze_time

    login_as subscriber1, scope: :user
    visit subscriber_root_path
  end

  context 'without using a floating widget' do
    it 'shows the correct number of Pomodoro Timer Sessions started' do
      visit subscriber_pomodoro_path

      click_button 'toggle-button'
      click_button 'toggle-button'

      click_button 'toggle-button'
      click_button 'toggle-button'

      travel 2.weeks do
        click_button 'toggle-button'
        click_button 'toggle-button'
      end

      logout

      login_as reporter, scope: :user
      visit reporter_feature_engagement_metrics_path

      within(:css, '.row.g-4') do
        chart_data = find('#pomodoro-sessions-by-week')['data-chart-chart-data-value']
        expect(chart_data).to have_content(
          { '5 Jan 2026 - 11 Jan 2026' => 2, '19 Jan 2026 - 25 Jan 2026' => 1 }.to_json, exact: true
        )
      end
    end
  end

  context 'when using the floating widget' do
    it 'shows the correct number of Pomodoro Timer Sessions started' do
      visit subscriber_pomodoro_path

      click_button 'toggle-button'
      click_button 'toggle-button'

      click_button 'Show Floating Timer'

      visit subscriber_project_path
      click_button 'toggle-button-floating'
      click_button 'toggle-button-floating'

      travel 1.week do
        click_button 'toggle-button-floating'
        click_button 'toggle-button-floating'
      end

      travel 1.month do
        click_button 'toggle-button-floating'
        click_button 'toggle-button-floating'
      end

      logout

      login_as reporter, scope: :user
      visit reporter_feature_engagement_metrics_path

      within(:css, '.row.g-4') do
        chart_data = find('#pomodoro-sessions-by-week')['data-chart-chart-data-value']
        expect(chart_data).to have_content(
          { '5 Jan 2026 - 11 Jan 2026' => 2, '12 Jan 2026 - 18 Jan 2026' => 1, '2 Feb 2026 - 8 Feb 2026' => 1 }.to_json,
          exact: true
        )
      end
    end
  end

  it 'shows the correct number of tasks created' do
    visit subscriber_project_path
    click_on '+ Task'
    fill_in 'Task name', with: 'Submit my assignment and report for my module'
    fill_in 'Description', with: 'Submit the code as a ZIP file and a report with details on how the programming
    project was implemented.'
    fill_in 'Due date', with: Time.zone.local(2026, 1, 5, 9, 0, 0).next_month.strftime('%m-%d-%Y')
    select 'Hard', from: 'Difficulty'
    click_on 'Create Task'

    travel 3.months do
      visit subscriber_project_path
      click_on '+ Task'
      fill_in 'Task name', with: 'Buy a present for a friend'
      fill_in 'Description', with: 'Buy a football-related present for John.'
      fill_in 'Due date', with: Time.zone.local(2026, 1, 5, 9, 0, 0).next_week.strftime('%m-%d-%Y')
      select 'Easy', from: 'Difficulty'
      click_on 'Create Task'
    end

    logout

    login_as reporter, scope: :user
    visit reporter_feature_engagement_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#tasks-created-by-week')['data-chart-chart-data-value']
      expect(chart_data).to have_content(
        { '5 Jan 2026 - 11 Jan 2026' => 1, '30 Mar 2026 - 5 Apr 2026' => 1 }.to_json,
        exact: true
      )
    end
  end

  it 'shows the correct number of tasks completed' do
    FactoryBot.create_list(:individual_task, 3, individual_project: subscriber1.individual_project)

    visit subscriber_project_path

    all('.task-items a').first.click
    page.accept_confirm do
      click_on 'Complete Task'
    end
    expect(page).to have_content('Task marked as complete.')

    travel 1.week do
      all('.task-items a').first.click
      page.accept_confirm do
        click_on 'Complete Task'
      end
      expect(page).to have_content('Task marked as complete.')
    end

    travel 2.weeks do
      all('.task-items a').first.click
      page.accept_confirm do
        click_on 'Complete Task'
      end
      expect(page).to have_content('Task marked as complete.')
    end

    logout

    login_as reporter, scope: :user
    visit reporter_feature_engagement_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#tasks-completed-by-week')['data-chart-chart-data-value']
      expect(chart_data).to have_content(
        { '5 Jan 2026 - 11 Jan 2026' => 1, '12 Jan 2026 - 18 Jan 2026' => 1, '19 Jan 2026 - 25 Jan 2026' => 1 }.to_json,
        exact: true
      )
    end
  end

  it 'shows the correct number of AI Tasks broken down' do
    FactoryBot.create(:individual_task, individual_project: subscriber1.individual_project)

    visit subscriber_project_path

    all('.task-items a').first.click
    click_on 'ai-button'
    FactoryBot.create(:ahoy_event, name: "User ##{subscriber1.id} #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
      }", user: subscriber1)
    click_on 'btn-close'
    logout

    login_as reporter, scope: :user
    visit reporter_feature_engagement_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#ai-task-breakdowns-by-week')['data-chart-chart-data-value']
      expect(chart_data).to have_content({ '5 Jan 2026 - 11 Jan 2026' => 1 }.to_json, exact: true)
    end
  end

  it 'shows the correct number of reminders' do
    visit subscriber_project_path
    click_on '+ Task'
    fill_in 'Task name', with: 'Submit my assignment and report for my module'
    fill_in 'Description', with: 'Submit the code as a ZIP file and a report with details on how the programming
    project was implemented.'
    fill_in 'Due date', with: DateTime.current.next_month.strftime('%m-%d-%Y')
    check 'reminder_enabled'
    fill_in 'Reminder date', with: DateTime.current.next_week.strftime('%m-%d-%Y')
    select 'Hard', from: 'Difficulty'
    click_on 'Create Task'
    logout

    login_as reporter, scope: :user
    visit reporter_feature_engagement_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#reminders-by-week')['data-chart-chart-data-value']
      expect(chart_data).to have_content({ '5 Jan 2026 - 11 Jan 2026' => 1 }.to_json, exact: true)
    end
  end

  it 'shows the correct number of notifications' do
    visit new_subscriber_shared_project_path
    fill_in 'Project Name', with: 'COM4525 Genesys'
    fill_in 'Description', with: 'Team 01 Assignment for COM4525 Genesys.'
    fill_in 'Skill 1', with: 'Frontend'
    fill_in 'Skill 2', with: 'Backend'
    fill_in 'Skill 3', with: 'Devops'
    fill_in 'invitee_email', with: "#{subscriber2.email},"
    click_on 'Create Project'
    logout

    login_as subscriber2, scope: :user
    visit subscriber_notifications_path
    click_on 'Shared Invites'
    click_on 'Accept'
    logout

    login_as reporter, scope: :user
    visit reporter_feature_engagement_metrics_path

    within(:css, '.row.g-4') do
      chart_data = find('#notifications-by-week')['data-chart-chart-data-value']
      expect(chart_data).to have_content({ '5 Jan 2026 - 11 Jan 2026' => 1 }.to_json, exact: true)
    end
  end
end
