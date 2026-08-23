# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  let!(:lead) { FactoryBot.create(:user, role: 'subscriber', first_name: 'lead', last_name: 'user') }
  let!(:member) { FactoryBot.create(:user, role: 'subscriber', first_name: 'member', last_name: 'user') }

  let!(:project) { FactoryBot.create(:team_project, name: 'Lead Project', description: 'Initial Description') }

  let!(:member_membership) { FactoryBot.create(:team_project_member, user: member, team_project: project) }

  let!(:categories) do
    [
      FactoryBot.create(:radar_category, team_project: project, name: 'Skill A'),
      FactoryBot.create(:radar_category, team_project: project, name: 'Skill B'),
      FactoryBot.create(:radar_category, team_project: project, name: 'Skill C')
    ]
  end

  describe 'Team Lead Settings Page' do
    before do
      FactoryBot.create(:team_project_member, :team_lead, user: lead, team_project: project)
      login_as(lead, scope: :user)

      visit subscriber_shared_project_path(project)

      within('.subscriber-top-navbar') do
        click_on 'Settings'
      end
    end

    context 'when looking at access control' do
      specify 'team member cannot access edit page and is redirected' do
        logout(lead)
        login_as(member, scope: :user)

        visit edit_subscriber_shared_project_path(project)

        expect(page).to have_current_path(subscriber_shared_projects_path)
        expect(page).to have_content('Only the team lead can do this action.')
      end
    end

    context 'when looking at project metadata' do
      specify 'allows updating project name and changes persist after navigation' do
        fill_in 'Project Name', with: 'Updated Project Name'
        fill_in 'Description', with: 'Updated Project Description'
        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))

        expect(page).to have_field('Project Name', with: 'Updated Project Name')
        expect(page).to have_field('Description', with: 'Updated Project Description')
      end
    end

    context 'when looking at radar categories' do
      specify 'allows setting between 3 and 5 categories - accept 5 categories' do
        fields = all("input[name='team_project[radar_categories][]']")

        fields[0].set('Backend')
        fields[1].set('Midend')
        fields[2].set('Frontend')
        fields[3].set('Happiness')
        fields[4].set('UI')

        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))

        expect(project.reload.radar_categories.pluck(:name)).to match_array(%w[Backend Midend Frontend
                                                                               Happiness UI])
      end

      specify 'allows setting 0 categories (delete all radar categories)', :js do
        fields = all("input[name='team_project[radar_categories][]']")

        fields[0].set('')
        fields[1].set('')
        fields[2].set('')
        fields[3].set('')
        fields[4].set('')

        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))

        expect(page).to have_field('team_project[radar_categories][]', with: '')
        expect(page).to have_field('team_project[radar_categories][]', with: '')
        expect(page).to have_field('team_project[radar_categories][]', with: '')
        expect(page).to have_field('team_project[radar_categories][]', with: '')
        expect(page).to have_field('team_project[radar_categories][]', with: '')

        expect(project.reload.radar_categories.pluck(:name)).to be_empty
      end

      specify 'rejects invalid category counts' do
        fields = all("input[name='team_project[radar_categories][]']")

        fields[0].set('Backend')
        fields[1].set('Midend')
        fields[2].set('')
        fields[3].set('')
        fields[4].set('')

        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))
        expect(page).to have_content('Skills Radar: You must enter either 0 or between 3 and 5 categories')

        expect(page).not_to have_field('team_project[radar_categories][]', with: 'Backend')
        expect(page).not_to have_field('team_project[radar_categories][]', with: 'Midend')
        expect(page).to have_field('team_project[radar_categories][]', with: 'Skill A')
        expect(page).to have_field('team_project[radar_categories][]', with: 'Skill B')
        expect(page).to have_field('team_project[radar_categories][]', with: 'Skill C')

        expect(project.reload.radar_categories.pluck(:name)).to contain_exactly('Skill A', 'Skill B', 'Skill C')
      end

      specify 'removing categories clears team member ratings', :js do
        FactoryBot.create(:radar_rating, team_project_member: member_membership, team_project: project,
                                         radar_category: categories[0], category_rating: 1)
        FactoryBot.create(:radar_rating, team_project_member: member_membership, team_project: project,
                                         radar_category: categories[1], category_rating: 2)
        FactoryBot.create(:radar_rating, team_project_member: member_membership, team_project: project,
                                         radar_category: categories[2], category_rating: 3)
        fields = all("input[name='team_project[radar_categories][]']")

        fields[0].set('')
        fields[1].set('')
        fields[2].set('')
        fields[3].set('')
        fields[4].set('')

        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))

        expect(page).to have_field('team_project[radar_categories][]', with: '')
        expect(page).to have_field('team_project[radar_categories][]', with: '')
        expect(page).to have_field('team_project[radar_categories][]', with: '')
        expect(page).to have_field('team_project[radar_categories][]', with: '')
        expect(page).to have_field('team_project[radar_categories][]', with: '')

        expect(project.reload.radar_categories.pluck(:name)).to be_empty

        expect(project.reload.radar_categories).to be_empty
        expect(member_membership.reload.radar_ratings).to be_empty
      end
    end

    context 'when looking at radar chart visibility' do
      specify 'allows viewing team member radar charts', :js do
        project_categories = project.reload.radar_categories
        FactoryBot.create(:radar_rating, team_project_member: member_membership, team_project: project,
                                         radar_category: project_categories[0], category_rating: 1)
        FactoryBot.create(:radar_rating, team_project_member: member_membership, team_project: project,
                                         radar_category: project_categories[1], category_rating: 2)
        FactoryBot.create(:radar_rating, team_project_member: member_membership, team_project: project,
                                         radar_category: project_categories[2], category_rating: 3)

        visit edit_subscriber_shared_project_path(project)

        button = nil

        within('.assignment-row-tp', text: 'member user') do
          button = find('.skills-btn')
          button.click
        end

        labels = JSON.parse(button['data-radar-labels'])
        scores = JSON.parse(button['data-radar-scores'])

        expect(labels).to contain_exactly('Skill A', 'Skill B', 'Skill C')
        expect(scores).to contain_exactly(1, 2, 3)

        expect(page).to have_selector('.radar-modal', visible: true)
        expect(page).to have_content('member user Radar Chart')
      end
    end

    context 'when looking at team member management' do
      specify 'shows all team members (apart from TL) and allows removing a team member' do
        within('.assignment-list') do
          expect(page).not_to have_content('lead user')
          expect(page).to have_content('member user')
        end

        within('.assignment-row-tp', text: 'member user') do
          find('.assignment-row__remove-btn').click
        end

        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))

        expect(project.reload.team_project_members.where(user: member)).to be_empty

        within('.assignment-list') do
          expect(page).not_to have_content('member user')
        end
      end
    end

    context 'when looking at invitations' do
      specify 'sends email invitation for new users', :js do
        mail_delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(InvitationMailer)
          .to receive(:new_shared_invite_email)
          .and_return(mail_delivery)

        find('.shared-project-invite-input').send_keys('emailuser@test.com')
        find('.shared-project-invite-input').send_keys(:enter)

        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))

        invite = SharedInvite.find_by(email: 'emailuser@test.com', team_project: project)
        expect(invite).not_to be_nil

        expect(InvitationMailer)
          .to have_received(:new_shared_invite_email)
          .with('emailuser@test.com', project)

        expect(mail_delivery).to have_received(:deliver_later)
      end

      specify 'creates notification for existing users', :js do
        existing_user = FactoryBot.create(:user, email: 'existing@test.com')

        find('.shared-project-invite-input').send_keys('existing@test.com')
        find('.shared-project-invite-input').send_keys(:enter)

        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))

        invite = SharedInvite.find_by(email: existing_user.email, team_project: project)
        expect(invite).not_to be_nil

        notification = Notification.find_by(user: existing_user, shared_invite: invite)

        expect(notification).not_to be_nil
        expect(notification.message).to include(project.name)

        logout(lead)
        login_as(existing_user, scope: :user)

        visit "#{subscriber_notifications_path}?tab=invites"

        within('.notifications-row') do
          expect(page).to have_content(project.name)
          expect(page).to have_button('Accept')
          expect(page).to have_button('Reject')
          click_button 'Accept'
        end

        expect(page).to have_current_path(subscriber_shared_project_path(project))
      end
    end

    context 'when looking at project lifecycle' do
      specify 'allows deleting the project and prevents future access for lead and member', :js do
        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))

        page.execute_script(<<~JS)
          window.confirm = () => true;

          const link = Array.from(document.querySelectorAll('a'))
            .find(a => a.textContent.trim() === 'Delete Project');

          link.click();
        JS

        expect(page).to have_current_path(subscriber_shared_projects_path)

        expect(TeamProject.exists?(project.id)).to be(false)

        within('.projects-grid') do
          expect(page).not_to have_content('Lead Project')
        end

        visit subscriber_shared_project_path(project)
        expect(page).to have_current_path(subscriber_shared_projects_path)
        expect(page).to have_content('Action Forbidden')

        logout(lead)
        login_as(member, scope: :user)

        visit subscriber_shared_projects_path

        within('.projects-grid') do
          expect(page).not_to have_content('Lead Project')
        end

        visit subscriber_shared_project_path(project)

        expect(page).to have_current_path(subscriber_shared_projects_path)
        expect(page).to have_content('Action Forbidden')
      end
    end

    context 'when looking at form behaviour' do
      specify 'renders team lead field and radar category inputs' do
        expect(page).to have_field('Team Lead', with: 'lead user', disabled: true)

        fields = all("input[name='team_project[radar_categories][]']")

        expect(fields.size).to eq(5)

        values = fields.map(&:value)

        expect(values).to include('Skill A', 'Skill B', 'Skill C')
      end

      specify 'image selection updates preview', :js do
        select 'Forest Theme', from: 'Project Image'

        expect(page).to have_selector(
          ".shared-project-preview-image[src*='forest-theme']"
        )

        click_on 'Update Project'

        visit subscriber_shared_projects_path

        within('.project-card', text: 'Lead Project') do
          expect(page).to have_selector("img[src*='forest-theme']")
        end
      end
    end
  end
end
