# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Project Invitations', type: :feature do
  let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
  let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }

  let!(:project) { FactoryBot.create(:team_project, name: 'Invite Project') }

  let!(:shared_invite) do
    FactoryBot.create(:shared_invite, :for_user, user: subscriber2, team_project: project)
  end

  let!(:notification) do
    FactoryBot.create(:notification,
                      user: subscriber2,
                      shared_invite: shared_invite,
                      message: "You've been invited to join the project \"Invite Project\" by subscriber1 user1.",
                      read: false)
  end

  before do
    FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project)
    login_as(subscriber2, scope: :user)
    visit "#{subscriber_notifications_path}?tab=invites"
  end

  describe 'Notifications Page' do
    specify 'user sees invitation notification' do
      expect(page).to have_content('Invite Project')
      expect(page).to have_button('Accept')
      expect(page).to have_button('Reject')
    end

    specify 'only unread invitations are displayed' do
      notification.update(read: true)
      visit subscriber_notifications_path

      expect(page).not_to have_content('Invite Project')
    end
  end

  describe 'Accepting Invitations' do
    specify 'user can accept an invitation and is added to the project and it appear on their shared projects page' do
      click_button 'Accept'

      expect(page).to have_current_path(subscriber_shared_project_path(project))
      expect(project.reload.users).to include(subscriber2)
      expect(page).to have_content("You've joined the project")

      visit subscriber_shared_projects_path

      within '.projects-grid' do
        expect(page).to have_content('Invite Project')
      end
    end

    specify 'invitation notification is deleted after user accepts' do
      click_button 'Accept'

      expect(page).to have_current_path(subscriber_shared_project_path(project))
      expect(project.reload.users).to include(subscriber2)
      expect(page).to have_content("You've joined the project")

      visit subscriber_notifications_path

      expect(page).not_to have_content('Invite Project')
    end

    specify 'user cannot accept invitation twice' do
      click_button 'Accept'

      visit subscriber_notifications_path

      expect(page).not_to have_content('Invite Project')
    end
  end

  describe 'Rejecting Invitations' do
    specify 'user can reject an invitation' do
      click_button 'Reject'

      expect(page).to have_current_path(subscriber_shared_projects_path)
      expect(page).to have_content("You've declined the invitation")
    end

    specify 'user is not added to the project after rejecting' do
      click_button 'Reject'

      expect(page).to have_current_path(subscriber_shared_projects_path)
      expect(page).to have_content("You've declined the invitation")
      within '.projects-grid' do
        expect(page).not_to have_content('Invite Project')
      end
      expect(project.reload.users).not_to include(subscriber2)
    end

    specify 'rejected invitation no longer appears in notifications' do
      click_button 'Reject'

      visit subscriber_notifications_path

      expect(page).not_to have_content('Invite Project')
    end
  end

  describe 'Edge Cases' do
    specify 'user cannot accept an invitation not meant for them' do
      logout(:user)
      login_as(subscriber1, scope: :user)

      visit subscriber_notifications_path

      expect(page).not_to have_content('Invite Project')
    end

    specify 'user sees empty state when no notifications exist' do
      notification.update(read: true)

      visit subscriber_notifications_path

      expect(page).not_to have_css('.notifications-row')
    end
  end
end
