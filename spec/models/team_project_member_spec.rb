# frozen_string_literal: true

# spec/models/team_project_member_spec.rb
# == Schema Information
#
# Table name: team_project_members
#
#  id                     :bigint           not null, primary key
#  joined_at              :datetime         not null
#  leaderboard_visibility :boolean          default(TRUE)
#  points                 :integer          default(0), not null
#  role                   :string           default("team_member")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  team_project_id        :bigint           not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_team_project_members_on_team_project_id  (team_project_id)
#  index_team_project_members_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_project_id => team_projects.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe TeamProjectMember, type: :model do
  let(:team_project) { FactoryBot.create(:team_project, name: 'Test Project') }
  let(:user) { FactoryBot.create(:user, role: 'subscriber') }
  let(:category) { FactoryBot.create(:radar_category, name: 'Test Project', team_project: team_project) }

  describe '#radar_rating' do
    let(:member) { FactoryBot.create(:team_project_member, user: user, team_project: team_project) }

    context 'when a rating exists' do
      it 'returns the stored rating' do
        FactoryBot.create(:radar_rating, team_project_member: member, radar_category: category, category_rating: 5)

        expect(member.radar_rating(category)).to be(5)
      end
    end

    context 'when rating exists but is blank' do
      it 'returns default value 3' do
        FactoryBot.create(:radar_rating, team_project_member: member, radar_category: category)

        expect(member.radar_rating(category)).to be(3)
      end
    end

    context 'when no rating exists' do
      it 'returns default value 3' do
        expect(member.radar_rating(category)).to be(3)
      end
    end
  end

  describe '#leaderboard_visibility?' do
    it 'returns true when visibility is true' do
      member = FactoryBot.create(:team_project_member, user: user, team_project: team_project,
                                                       leaderboard_visibility: true)

      expect(member.leaderboard_visibility?).to be(true)
    end

    it 'returns false when visibility is false' do
      member = FactoryBot.create(:team_project_member, user: user, team_project: team_project,
                                                       leaderboard_visibility: false)

      expect(member.leaderboard_visibility?).to be(false)
    end
  end
end
