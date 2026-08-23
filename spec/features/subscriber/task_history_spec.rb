# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscriber task history', type: :feature do
  let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
  let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }
  let!(:subscriber3) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber3', last_name: 'user3') }
  let!(:subscriber4) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber4', last_name: 'user4') }

  let!(:project) { FactoryBot.create(:team_project, name: 'Assignment Project') }

  let!(:member1) { FactoryBot.create(:team_project_member, user: subscriber1, team_project: project) }
  let!(:member2) { FactoryBot.create(:team_project_member, user: subscriber3, team_project: project) }

  let!(:shared_task1) do
    FactoryBot.create(:team_project_task, team_project: project, name: 'SP Task 1', due_date: 1.day.ago,
                                          difficulty: 'easy', points: 10, status_complete: true, updated_at: 1.day.ago)
  end
  let!(:shared_task2) do
    FactoryBot.create(:team_project_task, team_project: project, name: 'SP Task 2', due_date: 1.day.from_now,
                                          difficulty: 'easy', points: 10)
  end

  before do
    FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber1.individual_project, points: 40,
                                        due_date: 4.day.ago, status_complete: true, updated_at: 4.day.ago)
    FactoryBot.create(:individual_task, name: 'Task 2', individual_project: subscriber1.individual_project,
                                        due_date: 4.day.ago, status_complete: false)
    FactoryBot.create(:individual_task, name: 'Task 3', individual_project: subscriber1.individual_project, points: 30,
                                        due_date: 4.day.from_now, status_complete: true, updated_at: 1.day.ago)
    FactoryBot.create(:individual_task, name: 'Task 4', individual_project: subscriber1.individual_project,
                                        due_date: 4.day.from_now, status_complete: false)
    FactoryBot.create(:team_project_member, :team_lead, user: subscriber2, team_project: project)
    FactoryBot.create(:team_project_member, user: subscriber4, team_project: project)
    FactoryBot.create(:team_task_assignment, team_project_task: shared_task1, team_project_member: member1)
    FactoryBot.create(:team_task_assignment, team_project_task: shared_task1, team_project_member: member2)
    FactoryBot.create(:team_task_assignment, team_project_task: shared_task2, team_project_member: member1)
    login_as(subscriber1, scope: :user)
    visit subscriber_task_history_path
  end

  specify 'shows only completed individual tasks by default' do
    expect(page).to have_content('Task 1')
    expect(page).to have_content('Task 3')
    expect(page).not_to have_content('Task 2')
    expect(page).not_to have_content('Task 4')

    within(:xpath, "//tr[td[contains(., 'Task 1')]]") do
      expect(page).to have_content('40')
    end
    within(:xpath, "//tr[td[contains(., 'Task 3')]]") do
      expect(page).to have_content('30')
    end
  end

  specify 'shows only completed shared tasks by default' do
    click_link 'Shared Tasks'

    expect(page).to have_content('SP Task 1')
    expect(page).not_to have_content('SP Task 2')

    within(:xpath, "//tr[td[contains(., 'SP Task 1')]]") do
      expect(page).to have_content('Assignment Project')
      expect(page).to have_content('5')
    end
  end

  specify 'for users without any shared tasks completed, shows empty placeholder' do
    logout(:user)
    login_as(subscriber4, scope: :user)
    visit subscriber_task_history_path
    click_link 'Shared Tasks'
    expect(page).to have_content('No completed shared tasks yet.')
  end

  specify 'for users without any individual tasks completed, shows empty placeholder' do
    logout(:user)
    login_as(subscriber4, scope: :user)
    visit subscriber_task_history_path
    expect(page).to have_content('No completed individual tasks yet.')
  end
end
