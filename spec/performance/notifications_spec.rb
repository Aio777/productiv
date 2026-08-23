# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifications performance', type: :feature do
  let!(:subscriber) do
    FactoryBot.create(:user, role: 'subscriber')
  end

  before do
    seed_personal_task_reminders
    seed_team_task_reminders
    seed_shared_invite_notifications

    login_as(subscriber, scope: :user)
  end

  it 'loads personal task reminders in an acceptable time' do
    expect do
      visit subscriber_notifications_path(tab: 'reminders')

      expect(page).to have_content('Reminders')
      expect(page).to have_content('Reminder Task 1')
      expect(page).to have_content('Reminder Task 20')
      expect(page).to have_button('Mark as Read', minimum: 1)
    end.to perform_under(2500).ms
  end

  it 'marks a personal task reminder as read in an acceptable time' do
    visit subscriber_notifications_path(tab: 'reminders')

    expect do
      first(:button, 'Mark as Read').click

      expect(page).to have_content('Reminder Task')
    end.to perform_under(2000).ms
  end

  it 'loads team task reminders in an acceptable time' do
    expect do
      visit subscriber_notifications_path(tab: 'team_reminders')

      expect(page).to have_content('Team Reminders')
      expect(page).to have_content('Shared Reminder Task 1')
      expect(page).to have_content('Shared Reminder Task 20')
      expect(page).to have_link('Go To Task', minimum: 1)
      expect(page).to have_button('Mark as Read', minimum: 1)
    end.to perform_under(2500).ms
  end

  it 'loads shared project invites in an acceptable time' do
    expect do
      visit subscriber_notifications_path(tab: 'invites')

      expect(page).to have_content('Shared Invites')
      expect(page).to have_content('Invitation to Performance Invite Project 1')
      expect(page).to have_content('Invitation to Performance Invite Project 10')
      expect(page).to have_button('Accept', minimum: 1)
      expect(page).to have_button('Reject', minimum: 1)
    end.to perform_under(2500).ms
  end

  def seed_personal_task_reminders
    20.times do |index|
      task = FactoryBot.create(
        :individual_task,
        name: "Reminder Task #{index + 1}",
        individual_project: subscriber.individual_project,
        due_date: index.days.from_now,
        points: 10
      )

      FactoryBot.create(
        :notification,
        user: subscriber,
        individual_task: task,
        message: "Reminder for task #{index + 1}",
        read: false
      )
    end
  end

  def seed_team_task_reminders
    5.times do |project_index|
      team_project = FactoryBot.create(
        :team_project,
        name: "Performance Team Project #{project_index + 1}"
      )

      FactoryBot.create(
        :team_project_member,
        :team_lead,
        team_project: team_project
      )

      FactoryBot.create(
        :team_project_member,
        user: subscriber,
        team_project: team_project
      )

      4.times do |task_index|
        task_number = (project_index * 4) + task_index + 1
        task = FactoryBot.create(
          :team_project_task,
          team_project: team_project,
          name: "Shared Reminder Task #{task_number}",
          due_date: task_number.days.from_now,
          reminder_date: 1.day.ago
        )

        FactoryBot.create(
          :notification,
          user: subscriber,
          team_project_task: task,
          message: "Reminder for shared task #{task_number}",
          read: false
        )
      end
    end
  end

  def seed_shared_invite_notifications
    10.times do |index|
      team_project = FactoryBot.create(
        :team_project,
        name: "Performance Invite Project #{index + 1}"
      )

      shared_invite = FactoryBot.create(
        :shared_invite,
        team_project: team_project,
        email: subscriber.email
      )

      FactoryBot.create(
        :notification,
        user: subscriber,
        shared_invite: shared_invite,
        message: "Invitation to #{team_project.name}",
        read: false
      )
    end
  end
end
