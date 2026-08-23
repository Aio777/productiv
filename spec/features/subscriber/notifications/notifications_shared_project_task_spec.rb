# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notification reminders', :js, type: :feature do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber', last_name: 'user') }

  let!(:individual_task1) do
    FactoryBot.create(:individual_task, name: 'Write some tests', individual_project: subscriber.individual_project,
                                        reminder_date: 1.week.ago)
  end

  let!(:team_project) { FactoryBot.create(:team_project) }
  let!(:team_task) do
    FactoryBot.create(:team_project_task, name: 'Team Sprint Review', team_project: team_project,
                                          reminder_date: 1.day.ago)
  end
  let!(:team_task_tmr) do
    FactoryBot.create(:team_project_task, name: 'Reminder Tmr', team_project: team_project,
                                          reminder_date: 1.day.from_now)
  end

  let!(:lead_task) do
    FactoryBot.create(:team_project_task, name: 'Lead Oversight Task', team_project: team_project,
                                          reminder_date: 2.days.ago)
  end
  let!(:lead_task_tmr) do
    FactoryBot.create(:team_project_task, name: 'Lead Reminder Tmr', team_project: team_project,
                                          reminder_date: 2.days.from_now)
  end

  before do
    FactoryBot.create(:notification, individual_task: individual_task1, user: subscriber,
                                     message: individual_task1.name, read: false)
    FactoryBot.create(:individual_task, name: 'Write some documentation',
                                        individual_project: subscriber.individual_project, reminder_date: 2.week.ago)
    login_as(subscriber, scope: :user)
  end

  describe 'Team Reminders' do
    context 'when as an assigned member' do
      before do
        member = FactoryBot.create(:team_project_member, user: subscriber, team_project: team_project)
        FactoryBot.create(:team_task_assignment, team_project_task: team_task, team_project_member: member)
        FactoryBot.create(:team_task_assignment, team_project_task: team_task_tmr, team_project_member: member)

        FactoryBot.create(:notification, :with_team_task, user: subscriber, team_project_task: team_task,
                                                          message: team_task.name, read: false)
        visit "#{subscriber_notifications_path}?tab=team_reminders"
      end

      it 'displays the team task notification in the team reminders tab' do
        expect(page).to have_content('Team Sprint Review')
        expect(page).to have_css('.badge', text: 2) # 1 individual + 1 team
      end

      it 'does not display a reminder for an assigned team task with a future reminder date' do
        expect(page).not_to have_content('Reminder Tmr')
      end

      it 'allows marking team notifications as read' do
        within('.notification-task-row', text: 'Team Sprint Review') do
          click_button 'Mark as Read'
        end

        expect(page).to have_css('.badge', text: 1)
      end
    end

    context 'when as a team lead' do
      it 'shows notifications for tasks the user leads but is not assigned to' do
        team_lead_membership = FactoryBot.create(:team_project_member, :team_lead, user: subscriber,
                                                                                   team_project: team_project)
        expect(TeamTaskAssignment.exists?(team_project_task: lead_task,
                                          team_project_member: team_lead_membership)).to be(false)

        FactoryBot.create(:notification, :with_team_task, user: subscriber, team_project_task: lead_task,
                                                          message: lead_task.name, read: false)

        visit "#{subscriber_notifications_path}?tab=team_reminders"
        expect(page).to have_content('Lead Oversight Task')
      end

      it 'does not show a reminder for a task the user leads when the reminder date is in the future' do
        team_lead_membership = FactoryBot.create(:team_project_member, :team_lead, user: subscriber,
                                                                                   team_project: team_project)

        expect(TeamTaskAssignment.exists?(team_project_task: lead_task_tmr,
                                          team_project_member: team_lead_membership)).to be(false)

        visit "#{subscriber_notifications_path}?tab=team_reminders"

        expect(page).not_to have_content('Lead Reminder Tmr')
      end
    end
  end
end
