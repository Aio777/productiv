# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared projects overview performance', type: :feature do
  let!(:subscriber) do
    FactoryBot.create(
      :user,
      role: 'subscriber',
      first_name: 'Shared',
      last_name: 'Tester'
    )
  end

  before do
    login_as(subscriber, scope: :user)
  end

  it 'loads the shared projects index with multiple projects and tasks in an acceptable time' do
    seed_shared_projects

    expect do
      visit subscriber_shared_projects_path

      expect(page).to have_content('Your Shared Projects')
      expect(page).to have_link('Create New Project')
      expect(page).to have_content('Performance Project 01 - 60%')
      expect(page).to have_content('Performance Project 20 - 60%')
      expect(page).to have_css('.project-card', count: 20)
    end.to perform_under(2500).ms
  end

  it 'loads the shared project leaderboard with many members in an acceptable time' do
    team_project = seed_leaderboard_project

    expect do
      visit subscriber_shared_project_leaderboard_path(team_project)

      expect(page).to have_content('Team Leaderboard')
      expect(page).to have_content('Leaderboard Member 0030')
      expect(page).to have_content('Leaderboard Member 0001')
      expect(page).to have_css('.leaderboard-row', count: 31)
    end.to perform_under(2500).ms
  end

  def seed_shared_projects
    20.times do |project_index|
      team_project = FactoryBot.create(
        :team_project,
        name: "Performance Project #{(project_index + 1).to_s.rjust(2, '0')}"
      )

      FactoryBot.create(
        :team_project_member,
        :team_lead,
        user: subscriber,
        team_project: team_project
      )

      5.times do |task_index|
        FactoryBot.create(
          :team_project_task,
          team_project: team_project,
          name: "Project #{project_index + 1} Task #{task_index + 1}",
          due_date: (task_index + 1).days.from_now,
          status_complete: task_index < 3
        )
      end
    end
  end

  def seed_leaderboard_project
    team_project = FactoryBot.create(
      :team_project,
      name: 'Performance Leaderboard Project',
      leaderboard_visible: true
    )

    FactoryBot.create(
      :team_project_member,
      :team_lead,
      user: subscriber,
      team_project: team_project,
      points: 5
    )

    seed_leaderboard_members(team_project)

    team_project
  end

  def seed_leaderboard_members(team_project)
    current_time = Time.current

    users = 30.times.map do |index|
      member_number = (index + 1).to_s.rjust(4, '0')

      {
        first_name: 'Leaderboard',
        last_name: "Member #{member_number}",
        email: "leaderboard.member.#{member_number}@example.com",
        role: 'subscriber',
        encrypted_password: '',
        points: 0,
        layout: 15,
        was_subscriber: true,
        created_at: current_time,
        updated_at: current_time
      }
    end

    User.insert_all(users)

    member_users = User.where(email: users.pluck(:email)).order(:email)
    TeamProjectMember.insert_all(
      member_users.each_with_index.map do |user, index|
        {
          team_project_id: team_project.id,
          user_id: user.id,
          role: 'team_member',
          joined_at: current_time,
          leaderboard_visibility: true,
          points: (index + 1) * 10,
          created_at: current_time,
          updated_at: current_time
        }
      end
    )
  end
end
