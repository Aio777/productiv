# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscriber::NotificationsController', type: :request do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber') }
  let!(:team_project) { FactoryBot.create(:team_project, name: 'Project Trident') }
  let!(:individual_project) { FactoryBot.create(:individual_project, user: subscriber) }
  let!(:shared_invite) { FactoryBot.create(:shared_invite, team_project: team_project) }

  let!(:individual_task) do
    FactoryBot.create(
      :individual_task,
      name: 'Write some tests',
      individual_project: individual_project,
      reminder_date: 1.week.ago
    )
  end

  let!(:reminder) do
    FactoryBot.create(
      :notification,
      user: subscriber,
      individual_task: individual_task,
      read: false
    )
  end

  let!(:invitation) do
    FactoryBot.create(
      :notification,
      user: subscriber,
      shared_invite: shared_invite,
      read: false
    )
  end

  before do
    login_as(subscriber, scope: :user)
  end

  describe 'GET /subscriber/notifications' do
    it 'returns http success and assigns reminder variables by default' do
      get subscriber_notifications_path

      expect(response).to have_http_status(:success)
      expect(assigns(:reminders)).to include(reminder)
      expect(assigns(:invitations)).to be_empty
      expect(assigns(:active_tab)).to eq('reminders')
    end

    it 'loads invitations when the active tab is invites' do
      get subscriber_notifications_path, params: { tab: 'invites' }

      expect(response).to have_http_status(:success)
      expect(assigns(:invitations)).to include(invitation)
      expect(assigns(:reminders)).to be_empty
      expect(assigns(:active_tab)).to eq('invites')
    end

    it 'sets the active tab from params' do
      get subscriber_notifications_path, params: { tab: 'invites' }

      expect(assigns(:active_tab)).to eq('invites')
    end
  end

  describe 'PATCH /mark' do
    it 'toggles the read status of a notification' do
      expect do
        patch subscriber_mark_path(reminder)
      end.to change { reminder.reload.read }.from(false).to(true)
    end

    it 'responds to turbo_stream' do
      patch subscriber_mark_path(reminder), as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response).to have_http_status(:ok)
    end

    it 'redirects to index for HTML requests' do
      patch subscriber_mark_path(reminder)

      expect(response).to redirect_to(subscriber_notifications_path(tab: 'reminders'))
    end
  end

  describe 'PATCH /accept_invitation' do
    context 'when the user is not yet a member' do
      it 'creates a TeamProjectMember and destroys the invite' do
        expect do
          patch subscriber_accept_invitation_path(invitation)
        end.to change(TeamProjectMember, :count).by(1)
        expect(SharedInvite.exists?(shared_invite.id)).to be false
        expect(response).to redirect_to(subscriber_shared_project_path(team_project))
      end
    end

    context 'when the user is already a member' do
      before do
        create(:team_project_member, team_project: team_project, user: subscriber)
      end

      it 'does not create a duplicate member and redirects' do
        expect do
          patch subscriber_accept_invitation_path(invitation)
        end.not_to change(TeamProjectMember, :count)
        expect(response).to redirect_to(subscriber_shared_project_path(team_project))
        expect(flash[:notice]).to eq('You are already a member of this project.')
      end
    end

    context 'when the invitation/shared_invite is missing' do
      it 'returns a 404 alert' do
        invitation.update!(shared_invite: nil)
        patch subscriber_accept_invitation_path(invitation)
        expect(response).to have_http_status(:not_found)
        expect(flash[:alert]).to eq('Invitation not found.')
      end
    end
  end

  describe 'PATCH /decline_invitation' do
    context 'when the user is not yet a member' do
      it 'destroys the invite' do
        expect do
          patch subscriber_decline_invitation_path(invitation)
        end.not_to change(TeamProjectMember, :count)
        expect(SharedInvite.exists?(shared_invite.id)).to be false
        expect(response).to redirect_to(subscriber_shared_projects_path)
      end
    end

    context 'when the invitation/shared_invite is missing' do
      it 'returns a 404 alert' do
        invitation.update!(shared_invite: nil)
        patch subscriber_decline_invitation_path(invitation)
        expect(response).to have_http_status(:not_found)
        expect(flash[:alert]).to eq('Invitation not found.')
      end
    end
  end
end
