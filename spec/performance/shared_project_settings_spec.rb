# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared project settings performance', :js, type: :feature do
  let!(:subscriber) do
    FactoryBot.create(
      :user,
      role: 'subscriber',
      first_name: 'Performance',
      last_name: 'Tester'
    )
  end

  let!(:team_lead) do
    FactoryBot.create(
      :user,
      role: 'subscriber',
      first_name: 'Team',
      last_name: 'Lead'
    )
  end

  let!(:team_project) do
    FactoryBot.create(
      :team_project,
      name: 'Performance Shared Project',
      leaderboard_visible: true
    )
  end

  before do
    FactoryBot.create(
      :team_project_member,
      :team_lead,
      user: team_lead,
      team_project: team_project,
      points: 50
    )

    FactoryBot.create(
      :team_project_member,
      user: subscriber,
      team_project: team_project,
      points: 30
    )

    seed_radar_categories
    seed_extra_team_members

    login_as(subscriber, scope: :user)
  end

  it 'loads leaderboard settings in an acceptable time' do
    expect do
      visit subscriber_shared_project_settings_path(team_project)

      expect(page).to have_content("Performance's Project Preferences")
      expect(page).to have_content('Project Name')
      expect(page).to have_content('Description')
      expect(page).to have_content('Team Lead')
      expect(page).to have_content('Rate your Strengths')
      expect(page).to have_content('Project Members')
      expect(page).to have_content('Settings Member 001')
      expect(page).to have_content('Settings Member 030')
      expect(page).to have_content('Opt out of Leaderboard')
      expect(page).to have_button('Save Settings')
      expect(page).to have_content('Leave Project')
    end.to perform_under(3000).ms
  end

  def seed_radar_categories
    current_time = Time.current

    RadarCategory.insert_all(
      %w[Frontend Backend DevOps].map do |category_name|
        {
          team_project_id: team_project.id,
          name: category_name,
          created_at: current_time,
          updated_at: current_time
        }
      end
    )
  end

  def seed_extra_team_members
    current_time = Time.current

    users = 30.times.map do |index|
      member_number = (index + 1).to_s.rjust(3, '0')

      {
        first_name: 'Settings',
        last_name: "Member #{member_number}",
        email: "settings.member.#{member_number}@example.com",
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
      member_users.map do |user|
        {
          team_project_id: team_project.id,
          user_id: user.id,
          role: 'team_member',
          joined_at: current_time,
          leaderboard_visibility: true,
          points: 10,
          created_at: current_time,
          updated_at: current_time
        }
      end
    )
  end
end
