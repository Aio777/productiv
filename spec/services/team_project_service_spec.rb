# spec/services/team_project_service_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamProjectService, type: :service do
  describe '.process_params' do
    let(:params) do
      {
        image_path: '/uploads/project-image-1234567890abcdef1234.png',
        invite_emails: [' Test@Example.com ', 'test@example.com', ' second@example.com ', ''],
        radar_categories: [' Leadership ', ' Communication ', '', 'Teamwork ']
      }
    end

    it 'sanitizes image_path' do
      result = described_class.process_params(params)

      expect(result[:image_path]).to eq('project-image.png')
    end

    it 'normalizes invite_emails' do
      result = described_class.process_params(params)

      expect(result[:invite_emails]).to eq(['test@example.com', 'second@example.com'])
    end

    it 'normalizes radar_categories' do
      result = described_class.process_params(params)

      expect(result[:radar_categories]).to eq(%w[Leadership Communication Teamwork])
    end
  end

  describe '.update_member_radar_ratings' do
    let!(:team_project) { FactoryBot.create(:team_project) }
    let!(:current_member) { FactoryBot.create(:team_project_member, team_project: team_project) }
    let!(:category1) { FactoryBot.create(:radar_category, team_project: team_project) }
    let!(:category2) { FactoryBot.create(:radar_category, team_project: team_project) }
    let!(:category3) { FactoryBot.create(:radar_category, team_project: team_project) }

    let(:radar_ratings_params) do
      ActionController::Parameters.new(
        radar_ratings: {
          category1.id.to_s => '4',
          category2.id.to_s => '5',
          category3.id.to_s => '3'
        }
      ).permit(radar_ratings: {})
    end

    it 'replaces the existing radar ratings' do
      FactoryBot.create(
        :radar_rating,
        team_project_member: current_member,
        team_project: team_project,
        radar_category: category1,
        category_rating: 2
      )
      described_class.update_member_radar_ratings(current_member, radar_ratings_params)

      expect(current_member.radar_ratings.count).to eq(3)
      expect(
        current_member.radar_ratings.pluck(:radar_category_id, :category_rating)
      ).to contain_exactly(
        [category1.id, 4],
        [category2.id, 5],
        [category3.id, 3]
      )
    end
  end

  describe '.update_member_leaderboard_visibility' do
    let!(:team_project) { FactoryBot.create(:team_project) }
    let!(:current_member) do
      FactoryBot.create(:team_project_member, team_project: team_project, leaderboard_visibility: true)
    end

    context 'when hide_leaderboard is 1' do
      let(:params) { { hide_leaderboard: '1' } }

      it 'sets leaderboard_visibility to false' do
        described_class.update_member_leaderboard_visibility(current_member, params)

        expect(current_member.reload.leaderboard_visibility).to be(false)
      end
    end

    context 'when hide_leaderboard is not 1' do
      let(:params) { { hide_leaderboard: '0' } }

      it 'sets leaderboard_visibility to true' do
        current_member.update!(leaderboard_visibility: false)

        described_class.update_member_leaderboard_visibility(current_member, params)

        expect(current_member.reload.leaderboard_visibility).to be(true)
      end
    end
  end

  describe '.update_team_members' do
    let!(:team_lead_user) { FactoryBot.create(:user, first_name: 'Jane', last_name: 'Doe') }
    let!(:team_project) { FactoryBot.create(:team_project, name: 'Test Project') }

    let!(:existing_user) { FactoryBot.create(:user, email: 'member@example.com') }

    let(:team_project_params) do
      {
        invite_emails: ['newuser@example.com', 'member@example.com', '']
      }
    end

    before do
      FactoryBot.create(:team_project_member, team_project: team_project, user: team_lead_user, role: 'team_lead')
      FactoryBot.create(:user, email: 'newuser@example.com')
      allow(team_project).to receive(:team_lead).and_return(team_lead_user)
      FactoryBot.create(:team_project_member, team_project: team_project, user: existing_user)
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(InvitationMailer)
        .to receive(:new_shared_invite_email)
        .and_return(mail)
    end

    it 'FactoryBot.creates a shared invite for a new email' do
      expect do
        described_class.update_team_members(team_project, team_project_params)
      end.to change(SharedInvite, :count).by(1)

      expect(SharedInvite.last.email).to eq('newuser@example.com')
    end

    it 'does not FactoryBot.create a shared invite for an existing member' do
      described_class.update_team_members(team_project, team_project_params)

      expect(SharedInvite.where(email: 'member@example.com')).to be_empty
    end

    it 'FactoryBot.creates a notification for an invited existing user account' do
      expect do
        described_class.update_team_members(team_project, team_project_params)
      end.to change(Notification, :count).by(1)

      expect(Notification.last.message).to eq(
        'You\'ve been invited to join the project "Test Project" by Jane Doe.'
      )
    end
  end

  describe '.FactoryBot.create_new_team_project' do
    let!(:team_lead) { FactoryBot.create(:user, first_name: 'John', last_name: 'Smith') }
    let!(:team_project) { FactoryBot.create(:team_project, name: 'New Project') }

    let(:team_project_params) do
      {
        invite_emails: ['invitee@example.com', '']
      }
    end

    before do
      FactoryBot.create(:user, email: 'invitee@example.com')
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(InvitationMailer)
        .to receive(:new_shared_invite_email)
        .and_return(mail)
    end

    it 'FactoryBot.creates the team lead membership' do
      expect do
        described_class.create_new_team_project(team_project, team_lead, team_project_params)
      end.to change(TeamProjectMember, :count).by(1)

      membership = TeamProjectMember.last
      expect(membership.team_project).to eq(team_project)
      expect(membership.user).to eq(team_lead)
      expect(membership.role).to eq('team_lead')
    end

    it 'FactoryBot.creates a shared invite for invited emails' do
      expect do
        described_class.create_new_team_project(team_project, team_lead, team_project_params)
      end.to change(SharedInvite, :count).by(1)

      expect(SharedInvite.last.email).to eq('invitee@example.com')
    end

    it 'FactoryBot.creates a notification for users who already have an account' do
      expect do
        described_class.create_new_team_project(team_project, team_lead, team_project_params)
      end.to change(Notification, :count).by(1)

      expect(Notification.last.message).to eq(
        'You\'ve been invited to join the project "New Project" by John Smith.'
      )
    end
  end

  describe '.set_radar_categories' do
    let!(:team_project) { FactoryBot.create(:team_project) }

    context 'when categories are valid' do
      let(:team_project_params) do
        {
          radar_categories: %w[Leadership Communication Teamwork]
        }
      end

      it 'FactoryBot.creates radar categories' do
        described_class.set_radar_categories(team_project_params, team_project)

        expect(team_project.radar_categories.pluck(:name)).to match_array(
          %w[Leadership Communication Teamwork]
        )
      end
    end

    context 'when categories contain duplicates' do
      let(:team_project_params) do
        {
          radar_categories: %w[Leadership Communication Leadership]
        }
      end

      it 'raises an ArgumentError' do
        expect do
          described_class.set_radar_categories(team_project_params, team_project)
        end.to raise_error(ArgumentError, 'You must enter unique Skill Types')
      end
    end

    context 'when category count is less than 3' do
      let(:team_project_params) do
        {
          radar_categories: %w[Leadership Communication]
        }
      end

      it 'raises an ArgumentError' do
        expect do
          described_class.set_radar_categories(team_project_params, team_project)
        end.to raise_error(ArgumentError, 'You must enter either 0 or between 3 and 5 categories')
      end
    end

    context 'when category count is more than 5' do
      let(:team_project_params) do
        {
          radar_categories: %w[One Two Three Four Five Six]
        }
      end

      it 'raises an ArgumentError' do
        expect do
          described_class.set_radar_categories(team_project_params, team_project)
        end.to raise_error(ArgumentError, 'You must enter either 0 or between 3 and 5 categories')
      end
    end

    context 'when categories are empty' do
      let(:team_project_params) do
        {
          radar_categories: []
        }
      end

      it 'does not raise an error' do
        expect do
          described_class.set_radar_categories(team_project_params, team_project)
        end.not_to raise_error
      end
    end

    context 'when old categories exist that are not included anymore' do
      let(:team_project_params) do
        {
          radar_categories: %w[Leadership Communication Teamwork]
        }
      end

      it 'removes old categories and keeps only the provided ones' do
        FactoryBot.create(:radar_category, team_project: team_project, name: 'Old Category')
        described_class.set_radar_categories(team_project_params, team_project)

        expect(team_project.radar_categories.reload.pluck(:name)).to match_array(
          %w[Leadership Communication Teamwork]
        )
      end
    end
  end
end
