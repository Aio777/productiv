# frozen_string_literal: true

# spec/models/team_project_spec.rb
# == Schema Information
#
# Table name: team_projects
#
#  id                  :bigint           not null, primary key
#  description         :string
#  image_path          :string
#  leaderboard_visible :boolean          default(TRUE)
#  name                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
require 'rails_helper'

RSpec.describe TeamProject, type: :model do
  describe '#project_progress' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }

    it 'returns 50% when half of tasks are complete' do
      leading_project = FactoryBot.create(:team_project, name: 'Leading Project')
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)
      FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 1', due_date: 1.day.from_now)
      FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 2', due_date: 1.day.from_now,
                                            status_complete: true)

      expect(leading_project.project_progress).to eq(50)
    end

    it 'returns 100% when all tasks are complete' do
      leading_project = FactoryBot.create(:team_project, name: 'Leading Project')
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)
      FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 1', due_date: 1.day.from_now,
                                            status_complete: true)
      FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 2', due_date: 1.day.from_now,
                                            status_complete: true)

      expect(leading_project.project_progress).to eq(100)
    end

    it 'returns 0% when no tasks are complete' do
      leading_project = FactoryBot.create(:team_project, name: 'Leading Project')
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)
      FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 1', due_date: 1.day.from_now)
      FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 2', due_date: 1.day.from_now)

      expect(leading_project.project_progress).to eq(0)
    end
  end

  describe '#leaderboard_visible?' do
    it 'returns true when visibility is true' do
      leading_project = FactoryBot.create(:team_project, name: 'Leading Project', leaderboard_visible: true)

      expect(leading_project.leaderboard_visible?).to be(true)
    end

    it 'returns false when visibility is false' do
      leading_project = FactoryBot.create(:team_project, name: 'Leading Project', leaderboard_visible: false)

      expect(leading_project.leaderboard_visible?).to be(false)
    end
  end
end
