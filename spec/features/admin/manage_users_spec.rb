# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Admin manages users', type: :feature do
  let!(:admin) { FactoryBot.create(:user, role: 'admin', first_name: 'admin') }

  before do
    login_as(admin, scope: :user)
  end

  it 'lists all users', :js do
    user1 = FactoryBot.create(:user, role: 'subscriber', first_name: 'User1')
    user2 = FactoryBot.create(:user, role: 'reporter', first_name: 'User2')
    user3 = FactoryBot.create(:user, role: 'admin', first_name: 'User3')
    user4 = FactoryBot.create(:user, role: 'signee', first_name: 'User4')

    visit admin_users_path

    expect(page).to have_text(user1.email)
    expect(page).to have_text(user1.first_name)

    select 'Reporter', from: 'role-filter'

    expect(page).to have_text(user2.email)
    expect(page).to have_text(user2.first_name)

    select 'Admin', from: 'role-filter'

    expect(page).to have_text(user3.email)
    expect(page).to have_text(user3.first_name)
    expect(page).not_to have_text(admin.first_name)

    select 'Deactivated', from: 'role-filter'

    expect(page).to have_text(user4.email)
    expect(page).to have_text(user4.first_name)
  end

  it 'creates a new user', :js do
    visit admin_users_path

    click_on 'New User'

    fill_in 'First name', with: 'New User First'
    fill_in 'Last name', with: 'New User Last'
    fill_in 'Email', with: 'newuser@example.com'
    choose 'Reporter'

    click_on 'Save'

    select 'Reporter', from: 'role-filter'
    expect(page).to have_current_path(admin_users_path(role: 'reporter', sort: 'last_name'))
    expect(page).to have_text('New User First')
    expect(page).to have_text('New User Last')
    expect(page).to have_text('newuser@example.com')
  end

  it 'sends invitation email', :js do
    allow(User)
      .to receive(:invite!)
      .and_call_original

    visit admin_users_path

    click_on 'New User'

    fill_in 'First name', with: 'New User First'
    fill_in 'Last name', with: 'New User Last'
    fill_in 'Email', with: 'newuser@example.com'
    choose 'Reporter'

    click_on 'Save'

    select 'Reporter', from: 'role-filter'

    expect(page).to have_current_path(admin_users_path(role: 'reporter', sort: 'last_name'))
    expect(page).to have_text('New User First')
    expect(page).to have_text('New User Last')
    expect(page).to have_text('newuser@example.com')

    expect(User).to have_received(:invite!).with(
      hash_including(
        first_name: 'New User First',
        last_name: 'New User Last',
        email: 'newuser@example.com',
        role: 'reporter',
        invited_by_id: admin.id,
        was_subscriber: false,
        layout: 15
      )
    )
  end

  it 'change existing user to admin', :js do
    user = FactoryBot.create(:user, role: 'reporter')

    visit edit_admin_user_path(user)

    fill_in 'First name', with: 'Updated_first'
    fill_in 'Last name', with: 'Updated_last'
    choose 'Admin'
    click_button 'Save'

    select 'Admin', from: 'role-filter'
    expect(page).to have_current_path(admin_users_path(role: 'admin', sort: 'last_name'))
    expect(page).to have_text('Updated_first')
    expect(page).to have_text('Updated_last')
    expect(page).to have_text(user.email)
  end

  it 'change existing user to reporter', :js do
    user = FactoryBot.create(:user, role: 'admin')

    visit edit_admin_user_path(user)

    fill_in 'First name', with: 'Updated_first'
    fill_in 'Last name', with: 'Updated_last'
    choose 'Reporter'
    click_button 'Save'

    select 'Reporter', from: 'role-filter'
    expect(page).to have_current_path(admin_users_path(role: 'reporter', sort: 'last_name'))
    expect(page).to have_text('Updated_first')
    expect(page).to have_text('Updated_last')
    expect(page).to have_text(user.email)
  end

  it 'deactivate a user account', :js do
    user = FactoryBot.create(:user, role: 'admin')

    visit edit_admin_user_path(user)

    fill_in 'First name', with: 'Updated_first'
    fill_in 'Last name', with: 'Updated_last'
    choose 'Deactivated'
    click_button 'Save'

    select 'Deactivated', from: 'role-filter'
    expect(page).to have_current_path(admin_users_path(role: 'signee', sort: 'last_name'))
    expect(page).to have_text('Updated_first')
    expect(page).to have_text('Updated_last')
    expect(page).to have_text(user.email)
  end

  it 'does not allow downgrading an admin to subscriber' do
    user = FactoryBot.create(:user, role: 'admin')

    visit edit_admin_user_path(user)

    expect(page).to have_field('Admin', type: 'radio', with: 'admin')
    expect(page).to have_field('Reporter', type: 'radio', with: 'reporter')
    expect(page).to have_field('Deactivated', type: 'radio', with: 'signee')
    expect(page).not_to have_field('Subscriber', type: 'radio', with: 'subscriber')
  end

  it 'does not allow downgrading a reporter to subscriber' do
    user = FactoryBot.create(:user, role: 'reporter')

    visit edit_admin_user_path(user)

    expect(page).to have_field('Admin', type: 'radio', with: 'admin')
    expect(page).to have_field('Reporter', type: 'radio', with: 'reporter')
    expect(page).to have_field('Deactivated', type: 'radio', with: 'signee')
    expect(page).not_to have_field('Subscriber', type: 'radio', with: 'subscriber')
  end

  it 'does not allow upgrading a signee to a subscriber if was not one before' do
    user = FactoryBot.create(:user, role: 'signee', was_subscriber: false)

    visit edit_admin_user_path(user)

    expect(page).to have_field('Admin', type: 'radio', with: 'admin')
    expect(page).to have_field('Reporter', type: 'radio', with: 'reporter')
    expect(page).to have_field('Deactivated', type: 'radio', with: 'signee')
    expect(page).not_to have_field('Subscriber', type: 'radio', with: 'subscriber')
  end

  it 'allow upgrading a signee to a subscriber if was one before' do
    user = FactoryBot.create(:user, role: 'signee', was_subscriber: true)

    visit edit_admin_user_path(user)

    expect(page).to have_field('Admin', type: 'radio', with: 'admin')
    expect(page).to have_field('Reporter', type: 'radio', with: 'reporter')
    expect(page).to have_field('Deactivated', type: 'radio', with: 'signee')
    expect(page).to have_field('Subscriber', type: 'radio', with: 'subscriber')
  end

  describe 'deleting a user' do
    it 'deletes a subscriber team lead and cascades deletion of the entire shared project tree' do
      subscriber = FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1')
      project = FactoryBot.create(:team_project, name: 'Deletion Project')
      lead = FactoryBot.create(:team_project_member, :team_lead, user: subscriber, team_project: project)

      task = FactoryBot.create(:team_project_task, team_project: project, name: 'Delete Me', due_date: 1.day.from_now,
                                                   difficulty: 'easy', points: 10)
      FactoryBot.create(:team_task_assignment, team_project_task: task, team_project_member: lead)

      category = FactoryBot.create(:radar_category, team_project: project)
      FactoryBot.create(:radar_rating, radar_category: category, team_project: project, team_project_member: lead)

      invite = FactoryBot.create(:shared_invite, team_project: project)
      Notification.create!(user: subscriber, message: 'Invite', shared_invite: invite)

      visit admin_users_path
      within(:xpath, "//tr[td[contains(text(), '#{subscriber.first_name}')]]") do
        click_on 'Destroy'
      end
      visit admin_users_path
      expect(page).not_to have_text('subscriber1')

      expect(TeamProject.exists?(project.id)).to be false
      expect(TeamProjectTask.exists?(task.id)).to be false
      expect(TeamTaskAssignment.exists?(team_project_task_id: task.id)).to be false
      expect(RadarCategory.exists?(category.id)).to be false
      expect(RadarRating.exists?(radar_category_id: category.id)).to be false
      expect(SharedInvite.exists?(invite.id)).to be false
      expect(Notification.exists?(shared_invite_id: invite.id)).to be false
    end

    it 'deletes a subscriber team member but preserves the shared project and other members' do
      subscriber1 = FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1')
      subscriber2 = FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2')

      project = FactoryBot.create(:team_project, name: 'Preserve Project')

      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project)
      FactoryBot.create(:team_project_member, user: subscriber2, team_project: project)

      visit admin_users_path
      within(:xpath, "//tr[td[contains(text(), '#{subscriber2.first_name}')]]") do
        click_on 'Destroy'
      end

      project.reload

      expect(TeamProject.where(id: project.id)).to exist
      expect(project.team_project_members.count).to eq(1)
      expect(project.team_project_members.first.user_id).to eq(subscriber1.id)
    end

    it 'removes task assignments for a deleted member but keeps the tasks intact' do
      subscriber1 = FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1')
      subscriber2 = FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2')

      project = FactoryBot.create(:team_project, name: 'Task Assignment Test')

      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project)
      member_sub2 = FactoryBot.create(:team_project_member, user: subscriber2, team_project: project)

      task = FactoryBot.create(:team_project_task, team_project: project)
      FactoryBot.create(:team_task_assignment, team_project_task: task, team_project_member: member_sub2)

      visit admin_users_path
      within(:xpath, "//tr[td[contains(text(), '#{subscriber2.first_name}')]]") do
        click_on 'Destroy'
      end

      task.reload

      expect(TeamProjectTask.exists?(task.id)).to be true
      expect(task.team_task_assignments.count).to eq(0)
    end

    it 'deletes a subscriber with only individual tasks and cleans up all dependent data' do
      subscriber = FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1')

      project = subscriber.individual_project
      task = FactoryBot.create(:individual_task, individual_project: project)
      Notification.create!(user: subscriber, message: 'Reminder', individual_task: task)

      visit admin_users_path
      within(:xpath, "//tr[td[contains(text(), '#{subscriber.first_name}')]]") do
        click_on 'Destroy'
      end

      expect(IndividualProject.exists?(project.id)).to be false
      expect(IndividualTask.exists?(task.id)).to be false

      expect(Notification.exists?(individual_task_id: task.id)).to be false
      expect(Notification.exists?(user_id: subscriber.id)).to be false
    end

    it 'deletes a reporter and ensures they cannot log in', :js do
      reporter = FactoryBot.create(:user, role: 'reporter')

      visit admin_users_path
      select 'Reporters', from: 'role-filter'

      page.execute_script(<<~JS)
        window.confirm = () => true;
        window.alert = () => true;

        const row = Array.from(document.querySelectorAll('tr'))
          .find(tr => tr.textContent.includes("#{reporter.email}"));

        const destroyLink = Array.from(row.querySelectorAll('a'))
          .find(a => a.textContent.trim() === 'Destroy');

        destroyLink.click();
      JS

      expect(page).to have_no_text(reporter.email)
      expect(User.exists?(reporter.id)).to be false

      logout(:user)
      visit new_user_session_path

      fill_in 'Email', with: reporter.email
      fill_in 'Password', with: 'Password@1234'
      click_button 'Log In'

      expect(page).to have_current_path(new_user_session_path)
    end

    it 'deletes a signee and ensures they cannot log in', :js do
      signee = FactoryBot.create(:user, role: 'signee')

      visit admin_users_path
      select 'Deactivated', from: 'role-filter'

      page.execute_script(<<~JS)
        window.confirm = () => true;
        window.alert = () => true;

        const row = Array.from(document.querySelectorAll('tr'))
          .find(tr => tr.textContent.includes("#{signee.email}"));

        const destroyLink = Array.from(row.querySelectorAll('a'))
          .find(a => a.textContent.trim() === 'Destroy');

        destroyLink.click();
      JS

      expect(page).to have_no_text(signee.email)
      expect(User.exists?(signee.id)).to be false

      logout(:user)
      visit new_user_session_path

      fill_in 'Email', with: signee.email
      fill_in 'Password', with: 'Password@1234'
      click_button 'Log In'

      expect(page).to have_current_path(new_user_session_path)
    end

    it 'deletes a admin and ensures they cannot log in', :js do
      admin2 = FactoryBot.create(:user, role: 'admin', first_name: 'admin2', last_name: 'user2')

      visit admin_users_path
      select 'Admin', from: 'role-filter'

      page.execute_script(<<~JS)
        window.confirm = () => true;
        window.alert = () => true;

        const row = Array.from(document.querySelectorAll('tr'))
          .find(tr => tr.textContent.includes("#{admin2.first_name}"));

        const destroyLink = Array.from(row.querySelectorAll('a'))
          .find(a => a.textContent.trim() === 'Destroy');

        destroyLink.click();
      JS

      expect(page).to have_no_text(admin2.first_name)
      expect(User.exists?(admin2.id)).to be false

      logout(:user)
      visit new_user_session_path

      fill_in 'Email', with: admin2.email
      fill_in 'Password', with: 'Password@1234'
      click_button 'Log In'

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
