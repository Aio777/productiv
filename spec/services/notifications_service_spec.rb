# spec/services/notifications_service_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsService, type: :service do
  describe '.initialise_individual_task_notifications' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:other_user) { FactoryBot.create(:user) }
    let!(:individual_project) { FactoryBot.create(:individual_project, user: user) }
    let!(:other_project) { FactoryBot.create(:individual_project, user: other_user) }

    let!(:due_task) do
      FactoryBot.create(
        :individual_task,
        individual_project: individual_project,
        reminder_date: 1.hour.ago,
        status_complete: false,
        name: 'Due task'
      )
    end

    let!(:future_task) do
      FactoryBot.create(
        :individual_task,
        individual_project: individual_project,
        reminder_date: 1.hour.from_now,
        status_complete: false
      )
    end

    before do
      FactoryBot.create(:individual_task, individual_project: individual_project, reminder_date: 1.hour.ago,
                                          status_complete: true)
      FactoryBot.create(:individual_task, individual_project: other_project, reminder_date: 1.hour.ago,
                                          status_complete: false)
    end

    it 'creates notifications for incomplete due individual tasks belonging to the user' do
      expect do
        described_class.initialise_individual_task_notifications(user)
      end.to change(Notification, :count).by(1)

      notification = Notification.last

      expect(notification.user).to eq(user)
      expect(notification.individual_task).to eq(due_task)
      expect(notification.message).to eq('Due task')
      expect(notification.read).to be(false)
    end

    it 'does not create duplicate notifications' do
      described_class.initialise_individual_task_notifications(user)

      expect do
        described_class.initialise_individual_task_notifications(user)
      end.not_to(change(Notification, :count))
    end

    it 'destroys stale individual task notifications' do
      stale_notification = FactoryBot.create(
        :notification,
        user: user,
        individual_task: future_task,
        message: future_task.name
      )

      described_class.initialise_individual_task_notifications(user)

      expect(Notification.exists?(stale_notification.id)).to be(false)
    end
  end

  describe '.initialise_shared_task_notifications' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:team_lead) { FactoryBot.create(:user) }
    let!(:team_project) { FactoryBot.create(:team_project) }

    let!(:user_member) do
      FactoryBot.create(:team_project_member, team_project: team_project, user: user)
    end

    let!(:assigned_task) do
      FactoryBot.create(
        :team_project_task,
        team_project: team_project,
        reminder_date: 1.hour.ago,
        status_complete: false,
        name: 'Assigned task'
      )
    end

    let!(:future_task) do
      FactoryBot.create(
        :team_project_task,
        team_project: team_project,
        reminder_date: 1.hour.from_now,
        status_complete: false
      )
    end

    before do
      FactoryBot.create(:team_project_member, team_project: team_project, user: team_lead, role: 'team_lead')
      FactoryBot.create(:team_project_task, team_project: team_project, reminder_date: 1.hour.ago,
                                            status_complete: false, name: 'Lead task')
      FactoryBot.create(
        :team_task_assignment,
        team_project_task: assigned_task,
        team_project_member: user_member
      )
    end

    it 'creates notifications for assigned due shared tasks' do
      expect do
        described_class.initialise_shared_task_notifications(user)
      end.to change(Notification, :count).by(1)

      notification = Notification.last

      expect(notification.user).to eq(user)
      expect(notification.team_project_task).to eq(assigned_task)
      expect(notification.message).to eq('Assigned task')
      expect(notification.read).to be(false)
    end

    it 'creates notifications for due shared tasks when the user is team lead' do
      expect do
        described_class.initialise_shared_task_notifications(team_lead)
      end.to change(Notification, :count).by(1)

      expect(team_lead.notifications.pluck(:team_project_task_id)).to contain_exactly(assigned_task.id)
    end

    it 'does not create duplicate shared task notifications' do
      described_class.initialise_shared_task_notifications(user)

      expect do
        described_class.initialise_shared_task_notifications(user)
      end.not_to(change(Notification, :count))
    end

    it 'destroys stale shared task notifications' do
      stale_notification = FactoryBot.create(
        :notification,
        user: user,
        team_project_task: future_task,
        message: future_task.name
      )

      described_class.initialise_shared_task_notifications(user)

      expect(Notification.exists?(stale_notification.id)).to be(false)
    end
  end

  describe '.update_individual_task_notifications' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:individual_project) { FactoryBot.create(:individual_project, user: user) }

    context 'when the task is due for a reminder' do
      let!(:task) do
        FactoryBot.create(
          :individual_task,
          individual_project: individual_project,
          reminder_date: 1.hour.ago,
          name: 'Reminder task'
        )
      end

      it 'creates a notification' do
        expect do
          described_class.update_individual_task_notifications(task)
        end.to change(Notification, :count).by(1)

        expect(Notification.last.user).to eq(user)
        expect(Notification.last.individual_task).to eq(task)
      end
    end

    context 'when the task is not due for a reminder' do
      let!(:task) do
        FactoryBot.create(
          :individual_task,
          individual_project: individual_project,
          reminder_date: 1.hour.from_now
        )
      end

      it 'does not create a notification' do
        expect do
          described_class.update_individual_task_notifications(task)
        end.not_to(change(Notification, :count))
      end
    end

    it 'destroys the existing notification before updating' do
      task = FactoryBot.create(
        :individual_task,
        individual_project: individual_project,
        reminder_date: nil
      )

      old_notification = FactoryBot.create(
        :notification,
        user: user,
        individual_task: task,
        message: 'Old notification'
      )

      described_class.update_individual_task_notifications(task)

      expect(Notification.exists?(old_notification.id)).to be(false)
    end
  end

  describe '.update_shared_task_notifications' do
    let!(:team_project) { FactoryBot.create(:team_project) }
    let!(:team_lead) { FactoryBot.create(:user) }
    let!(:member_user) { FactoryBot.create(:user) }

    let!(:member) do
      FactoryBot.create(:team_project_member, team_project: team_project, user: member_user)
    end

    let!(:task) do
      FactoryBot.create(
        :team_project_task,
        team_project: team_project,
        reminder_date: 1.hour.ago,
        name: 'Shared reminder'
      )
    end

    before do
      FactoryBot.create(:team_project_member, team_project: team_project, user: team_lead, role: 'team_lead')
      FactoryBot.create(
        :team_task_assignment,
        team_project_task: task,
        team_project_member: member
      )
    end

    it 'creates notifications for assigned members and the team lead' do
      expect do
        described_class.update_shared_task_notifications(task)
      end.to change(Notification, :count).by(2)

      expect(Notification.pluck(:user_id,
                                :team_project_task_id)).to contain_exactly([member_user.id, task.id],
                                                                           [team_lead.id, task.id])
    end

    it 'destroys existing notifications before recreating them' do
      old_notification = FactoryBot.create(
        :notification,
        user: member_user,
        team_project_task: task,
        message: 'Old notification'
      )

      described_class.update_shared_task_notifications(task)

      expect(Notification.exists?(old_notification.id)).to be(false)
    end
  end

  describe '.destroy_shared_task_notifications' do
    let!(:task) { FactoryBot.create(:team_project_task) }

    it 'destroys all notifications for the shared task' do
      FactoryBot.create(:notification, team_project_task: task)

      expect do
        described_class.destroy_shared_task_notifications(task)
      end.to change(Notification, :count).by(-1)
    end
  end

  describe '.destroy_individual_task_notifications' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:individual_project) { FactoryBot.create(:individual_project, user: user) }
    let!(:task) { FactoryBot.create(:individual_task, individual_project: individual_project) }

    it 'destroys the notification for the individual task' do
      FactoryBot.create(:notification, user: user, individual_task: task)

      expect do
        described_class.destroy_individual_task_notifications(task)
      end.to change(Notification, :count).by(-1)
    end
  end
end
