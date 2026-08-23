# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SharedInviteService, type: :service do
  shared_examples 'creates shared invites' do |method_name|
    let!(:lead) { create(:user, first_name: 'Test', last_name: 'Lead') }
    let!(:team_project) { create(:team_project, name: 'Test Project') }

    let(:mail_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    before do
      allow(InvitationMailer)
        .to receive(:new_shared_invite_email)
        .and_return(mail_delivery)
    end

    context 'when invite emails are provided' do
      let(:team_project_params) do
        {
          invite_emails: ['invited@example.com']
        }
      end

      it 'creates a shared invite' do
        described_class.public_send(method_name, lead, team_project, team_project_params)

        expect(SharedInvite.find_by(team_project: team_project, email: 'invited@example.com')).to be_present
      end

      it 'sends an invite email' do
        described_class.public_send(method_name, lead, team_project, team_project_params)

        expect(InvitationMailer).to have_received(:new_shared_invite_email)
          .with('invited@example.com', team_project)
      end
    end

    context 'when invite email belongs to an existing user' do
      let!(:user) { create(:user, email: 'user@example.com') }

      let(:team_project_params) do
        {
          invite_emails: ['user@example.com']
        }
      end

      it 'creates a notification for the user' do
        described_class.public_send(method_name, lead, team_project, team_project_params)

        invite = SharedInvite.find_by(team_project: team_project, email: 'user@example.com')

        expect(
          Notification.find_by(
            user: user,
            shared_invite: invite,
            message: 'You\'ve been invited to join the project "Test Project" by Test Lead.'
          )
        ).to be_present
      end
    end

    context 'when invite email is blank' do
      let(:team_project_params) do
        {
          invite_emails: ['', nil, '   ']
        }
      end

      it 'does not create shared invites' do
        described_class.public_send(method_name, lead, team_project, team_project_params)

        expect(SharedInvite.count).to eq(0)
      end

      it 'does not send invite emails' do
        described_class.public_send(method_name, lead, team_project, team_project_params)

        expect(InvitationMailer).not_to have_received(:new_shared_invite_email)
      end
    end

    context 'when a shared invite already exists for the email' do
      let(:team_project_params) do
        {
          invite_emails: ['invited@example.com']
        }
      end

      before do
        create(:shared_invite, team_project: team_project, email: 'invited@example.com')
      end

      it 'does not create a duplicate shared invite' do
        described_class.public_send(method_name, lead, team_project, team_project_params)

        expect(SharedInvite.where(team_project: team_project, email: 'invited@example.com').count).to eq(1)
      end

      it 'does not send another invite email' do
        described_class.public_send(method_name, lead, team_project, team_project_params)

        expect(InvitationMailer).not_to have_received(:new_shared_invite_email)
      end
    end

    context 'when the user is already a project member' do
      let!(:user) { create(:user, email: 'member@example.com') }
      let(:team_project_params) do
        {
          invite_emails: ['member@example.com']
        }
      end

      before do
        create(:team_project_member, team_project: team_project, user: user)
      end

      it 'does not create a shared invite' do
        described_class.public_send(method_name, lead, team_project, team_project_params)

        expect(SharedInvite.find_by(team_project: team_project, email: 'member@example.com')).to be_nil
      end

      it 'does not send an invite email' do
        described_class.public_send(method_name, lead, team_project, team_project_params)

        expect(InvitationMailer).not_to have_received(:new_shared_invite_email)
      end
    end
  end

  describe '.create_shared_invites_on_create' do
    it_behaves_like 'creates shared invites', :create_shared_invites_on_create
  end

  describe '.create_shared_invites_on_update' do
    it_behaves_like 'creates shared invites', :create_shared_invites_on_update
  end
end
