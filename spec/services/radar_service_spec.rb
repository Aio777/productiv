# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RadarService, type: :service do
  describe '.update_radar_ratings' do
    let!(:team_project) { create(:team_project) }
    let!(:member) { create(:team_project_member, team_project: team_project) }
    let!(:category_one) { create(:radar_category, team_project: team_project, name: 'Communication') }
    let!(:category_two) { create(:radar_category, team_project: team_project, name: 'Leadership') }

    let(:radar_ratings_params) do
      {
        radar_ratings: {
          category_one.id.to_s => '4',
          category_two.id.to_s => '2'
        }
      }
    end

    context 'when the member has no existing radar ratings' do
      it 'creates radar ratings for each submitted category' do
        described_class.update_radar_ratings(member, radar_ratings_params)

        expect(member.radar_ratings.count).to eq(2)
      end

      it 'sets the correct rating values' do
        described_class.update_radar_ratings(member, radar_ratings_params)

        expect(member.radar_ratings.find_by(radar_category: category_one).category_rating).to eq(4)
        expect(member.radar_ratings.find_by(radar_category: category_two).category_rating).to eq(2)
      end

      it 'assigns ratings to the member team project' do
        described_class.update_radar_ratings(member, radar_ratings_params)

        member.radar_ratings.each do |rating|
          expect(rating.team_project).to eq(team_project)
          expect(rating.team_project_member).to eq(member)
        end
      end
    end

    context 'when the member already has radar ratings' do
      before do
        create(
          :radar_rating,
          team_project_member: member,
          team_project: team_project,
          radar_category: category_one,
          category_rating: 1
        )
      end

      it 'removes old ratings before creating new ones' do
        described_class.update_radar_ratings(member, radar_ratings_params)

        expect(member.radar_ratings.count).to eq(2)
        expect(member.radar_ratings.find_by(radar_category: category_one).category_rating).to eq(4)
      end
    end
  end

  describe '.set_radar_categories' do
    let!(:team_project) { create(:team_project) }

    context 'when no radar categories exist yet' do
      let(:radar_categories) { %w[Communication Leadership] }

      it 'creates the submitted radar categories' do
        described_class.set_radar_categories(team_project, radar_categories)

        expect(team_project.radar_categories.pluck(:name)).to match_array(
          %w[Communication Leadership]
        )
      end
    end

    context 'when some radar categories already exist' do
      let(:radar_categories) { %w[Communication Leadership] }

      before do
        create(:radar_category, team_project: team_project, name: 'Communication')
      end

      it 'keeps existing matching categories' do
        described_class.set_radar_categories(team_project, radar_categories)

        expect(team_project.radar_categories.where(name: 'Communication').count).to eq(1)
      end

      it 'creates missing categories' do
        described_class.set_radar_categories(team_project, radar_categories)

        expect(team_project.radar_categories.exists?(name: 'Leadership')).to be(true)
      end
    end

    context 'when existing categories are not included in submitted categories' do
      let(:radar_categories) { ['Communication'] }

      before do
        create(:radar_category, team_project: team_project, name: 'Old Skill')
        create(:radar_category, team_project: team_project, name: 'Old Skill')
      end

      it 'destroys categories that are no longer included' do
        described_class.set_radar_categories(team_project, radar_categories)

        expect(team_project.radar_categories.exists?(name: 'Old Skill')).to be(false)
      end

      it 'keeps categories that are still included' do
        described_class.set_radar_categories(team_project, radar_categories)

        expect(team_project.radar_categories.exists?(name: 'Communication')).to be(true)
      end
    end

    context 'when duplicate category names are submitted' do
      let(:radar_categories) { %w[Communication Communication] }

      it 'does not create duplicate categories' do
        described_class.set_radar_categories(team_project, radar_categories)

        expect(team_project.radar_categories.where(name: 'Communication').count).to eq(1)
      end
    end
  end
end
