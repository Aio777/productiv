# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  let!(:user) do
    FactoryBot.create(:user, role: 'subscriber', first_name: 'creator', last_name: 'user')
  end

  before do
    login_as(user, scope: :user)

    visit subscriber_shared_projects_path
    click_on 'Create New Project'
  end

  describe 'Create New Shared Project' do
    context 'when rendering the form' do
      specify 'displays required fields' do
        expect(page).to have_field('Project Name')
        expect(page).to have_field('Description')
        expect(page).to have_field('Team Lead', with: 'creator user', disabled: true)
        expect(page).to have_selector("input[name='team_project[radar_categories][]']", count: 5)
        expect(page).to have_select('Project Image')
        expect(page).to have_field('invitee_email')
      end
    end

    context 'when creation is successful' do
      specify 'creates a project with valid inputs' do
        fill_in 'Project Name', with: 'My New Project'
        fill_in 'Description', with: 'This is a test project'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Frontend')
        fields[2].set('DevOps')

        expect do
          click_button 'Create Project'
        end.to change(TeamProject, :count).by(1)

        expect(page).to have_current_path(subscriber_shared_projects_path)
      end

      specify 'New project is visible in shared projects list' do
        project1 = FactoryBot.create(:team_project, name: 'My New Project')
        FactoryBot.create(:team_project_member, :team_lead, user: user, team_project: project1)

        visit subscriber_shared_projects_path

        expect(project1.name).to eq('My New Project')

        within('.projects-grid') do
          expect(page).to have_content('My New Project')
        end
      end

      specify 'creates team lead membership automatically and can see in the settings' do
        project1 = FactoryBot.create(:team_project, name: 'My New Project')
        FactoryBot.create(:team_project_member, :team_lead, user: user, team_project: project1)

        visit edit_subscriber_shared_project_path(project1)

        expect(page).to have_field('Team Lead', with: 'creator user', disabled: true)
      end

      specify 'sets radar categories correctly and accepts 3 fields', :js do
        fill_in 'Project Name', with: 'Radar Project'
        fill_in 'Description', with: 'Testing radar categories'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Frontend')
        fields[2].set('DevOps')

        click_button 'Create Project'

        project = TeamProject.last
        category_names = project.radar_categories.pluck(:name)
        expect(category_names).to match_array(%w[Backend Frontend DevOps])

        click_on 'Radar Project'

        within('.subscriber-top-navbar') do
          click_on 'Settings'
        end

        fields = all("input[name='team_project[radar_categories][]']")
        expect(fields.size).to eq(5)
        values = fields.map(&:value)

        expect(values).to include('Backend', 'Frontend', 'DevOps', '', '')
      end
    end

    context 'when validating radar categories' do
      specify 'accepts 5 categories' do
        fill_in 'Project Name', with: 'Radar Project'
        fill_in 'Description', with: 'Testing radar categories'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Midend')
        fields[2].set('Frontend')
        fields[3].set('Happiness')
        fields[4].set('UI')

        click_button 'Create Project'

        expect(page).to have_current_path(subscriber_shared_projects_path)
        expect(page).to have_content('Project was successfully created')

        project = TeamProject.last

        project_category_names = project.radar_categories.pluck(:name)
        expect(project_category_names).to match_array(%w[Backend Midend Frontend Happiness UI])
      end

      specify 'accepts 0 categories' do
        fill_in 'Project Name', with: 'Radar Project'
        fill_in 'Description', with: 'Testing radar categories'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('')
        fields[1].set('')
        fields[2].set('')
        fields[3].set('')
        fields[4].set('')

        click_button 'Create Project'

        expect(page).to have_current_path(subscriber_shared_projects_path)
        expect(page).to have_content('Project was successfully created')

        project = TeamProject.last
        expect(project.radar_categories).to be_empty
      end

      specify 'rejects less than 3 categories (except 0)' do
        fill_in 'Project Name', with: 'Radar Project'
        fill_in 'Description', with: 'Testing radar categories'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('')
        fields[2].set('')
        fields[3].set('')
        fields[4].set('')

        expect do
          click_button 'Create Project'
        end.not_to(change(TeamProject, :count))

        expect(page).to have_current_path(new_subscriber_shared_project_path)
        expect(page).to have_content('Skills Radar: You must enter either 0 or between 3 and 5 categories')
      end

      specify 'rejects duplicate category names' do
        fill_in 'Project Name', with: 'Radar Project'
        fill_in 'Description', with: 'Testing radar categories'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Backend')
        fields[2].set('')
        fields[3].set('')
        fields[4].set('')

        expect do
          click_button 'Create Project'
        end.not_to(change(TeamProject, :count))

        expect(page).to have_current_path(new_subscriber_shared_project_path)
        expect(page).to have_content('Skills Radar: You must enter unique Skill Types')
      end
    end

    context 'when selecting image' do
      specify 'updates preview when selecting an image', :js do
        select 'Forest Theme', from: 'Project Image'

        expect(page).to have_selector(
          ".shared-project-preview-image[src*='forest-theme']"
        )
      end

      specify 'persists selected image after creation' do
        fill_in 'Project Name', with: 'Image Project'
        fill_in 'Description', with: 'Testing image persistence'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Frontend')
        fields[2].set('DevOps')

        select 'Forest Theme', from: 'Project Image'

        click_button 'Create Project'

        project = TeamProject.last
        expect(project.image_path).to include('forest-theme')
      end
    end

    context 'when inviting users' do
      specify 'creates shared invites for entered emails', :js do
        mail_delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(InvitationMailer)
          .to receive(:new_shared_invite_email)
          .and_return(mail_delivery)

        fill_in 'Project Name', with: 'Invite Project'
        fill_in 'Description', with: 'Testing invites'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Frontend')
        fields[2].set('DevOps')

        find('.shared-project-invite-input').send_keys('user1@test.com')
        find('.shared-project-invite-input').send_keys(:enter)

        find('.shared-project-invite-input').send_keys('user2@test.com')
        find('.shared-project-invite-input').send_keys(:enter)

        expect do
          click_button 'Create Project'
        end.to change(SharedInvite, :count).by(2)

        project = TeamProject.last
        invites = SharedInvite.where(team_project: project).pluck(:email)

        expect(invites).to contain_exactly('user1@test.com', 'user2@test.com')

        expect(InvitationMailer)
          .to have_received(:new_shared_invite_email)
          .with('user1@test.com', project)

        expect(InvitationMailer)
          .to have_received(:new_shared_invite_email)
          .with('user2@test.com', project)
      end

      specify 'creates notifications for existing users', :js do
        mail_delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(InvitationMailer)
          .to receive(:new_shared_invite_email)
          .and_return(mail_delivery)

        existing_user = FactoryBot.create(:user, email: 'existing@test.com')

        fill_in 'Project Name', with: 'Invite Project'
        fill_in 'Description', with: 'Testing invites'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Frontend')
        fields[2].set('DevOps')

        find('.shared-project-invite-input').send_keys('existing@test.com')
        find('.shared-project-invite-input').send_keys(:enter)

        expect do
          click_button 'Create Project'
        end.to change(SharedInvite, :count).by(1)

        project = TeamProject.last
        invite = SharedInvite.find_by(email: existing_user.email, team_project: project)
        expect(invite).not_to be_nil

        expect(InvitationMailer)
          .to have_received(:new_shared_invite_email)
          .with('existing@test.com', project)

        expect(mail_delivery).to have_received(:deliver_later)

        notification = Notification.find_by(user: existing_user, shared_invite: invite)
        expect(notification).not_to be_nil
        expect(notification.message).to include(project.name)

        logout(user)
        login_as(existing_user, scope: :user)

        visit "#{subscriber_notifications_path}?tab=invites"

        within('.notifications-row') do
          expect(page).to have_content(project.name)
          expect(page).to have_button('Accept')
          expect(page).to have_button('Reject')
        end
      end

      specify 'sends email invitations', :js do
        mail_delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(InvitationMailer)
          .to receive(:new_shared_invite_email)
          .and_return(mail_delivery)

        fill_in 'Project Name', with: 'Invite Project'
        fill_in 'Description', with: 'Testing invites'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Frontend')
        fields[2].set('DevOps')

        find('.shared-project-invite-input').send_keys('emailuser@test.com')
        find('.shared-project-invite-input').send_keys(:enter)

        click_button 'Create Project'

        project = TeamProject.last

        expect(page).to have_current_path(subscriber_shared_projects_path)

        expect(InvitationMailer)
          .to have_received(:new_shared_invite_email)
          .with('emailuser@test.com', project)

        expect(mail_delivery).to have_received(:deliver_later)
      end

      specify 'does not create duplicate invites', :js do
        mail_delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(InvitationMailer)
          .to receive(:new_shared_invite_email)
          .and_return(mail_delivery)

        existing_user = FactoryBot.create(:user, email: 'emailuser@test.com')

        fill_in 'Project Name', with: 'Invite Project'
        fill_in 'Description', with: 'Testing invites'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Frontend')
        fields[2].set('DevOps')

        find('.shared-project-invite-input').send_keys('emailuser@test.com')
        find('.shared-project-invite-input').send_keys(:enter)
        find('.shared-project-invite-input').send_keys('emailuser@test.com')
        find('.shared-project-invite-input').send_keys(:enter)

        expect do
          click_button 'Create Project'
        end.to change(SharedInvite, :count).by(1)

        project = TeamProject.last
        invites = SharedInvite.where(team_project: project, email: 'emailuser@test.com')
        expect(invites.count).to eq(1)

        expect(InvitationMailer)
          .to have_received(:new_shared_invite_email)
          .with('emailuser@test.com', project)
          .once

        expect(mail_delivery).to have_received(:deliver_later).once

        logout(user)
        login_as(existing_user, scope: :user)

        visit "#{subscriber_notifications_path}?tab=invites"

        rows = all('.notifications-row')

        expect(rows.size).to eq(1)

        within(rows.first) do
          expect(page).to have_content(project.name)
          expect(page).to have_button('Accept')
          expect(page).to have_button('Reject')
        end
      end

      specify 'non-existent user gets invitation email & receives notification after signing up', :js do
        mail_delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(InvitationMailer)
          .to receive(:new_shared_invite_email)
          .and_return(mail_delivery)

        fill_in 'Project Name', with: 'Invite Project'
        fill_in 'Description', with: 'Testing invites'

        fields = all("input[name='team_project[radar_categories][]']")
        fields[0].set('Backend')
        fields[1].set('Frontend')
        fields[2].set('DevOps')

        find('.shared-project-invite-input').send_keys('newuser@test.com')
        find('.shared-project-invite-input').send_keys(:enter)

        expect do
          click_button 'Create Project'
        end.to change(SharedInvite, :count).by(1)

        project = TeamProject.last
        invites = SharedInvite.where(team_project: project, email: 'newuser@test.com')
        expect(invites.count).to eq(1)

        expect(InvitationMailer)
          .to have_received(:new_shared_invite_email)
          .with('newuser@test.com', project)

        expect(mail_delivery).to have_received(:deliver_later)

        new_user = FactoryBot.create(:user, email: 'newuser@test.com')
        UserService.initialise_shared_invites(new_user)

        logout(user)
        login_as(new_user, scope: :user)

        visit "#{subscriber_notifications_path}?tab=invites"

        rows = all('.notifications-row')

        expect(rows.size).to eq(1)

        within(rows.first) do
          expect(page).to have_content(project.name)
          expect(page).to have_button('Accept')
          expect(page).to have_button('Reject')
        end
      end
    end
  end
end
