# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Individual Tasks', type: :request do
  let!(:subscriber) { create(:user, role: 'subscriber') }

  before do
    login_as(subscriber, scope: :user)
  end

  describe 'POST /subscriber/individual_tasks' do
    it 'creates an individual task with permitted params' do
      expect do
        post subscriber_individual_tasks_path, params: {
          individual_task: {
            name: 'My Task',
            description: 'This is my task.',
            due_date: 1.week.from_now,
            reminder_date: 2.days.from_now,
            difficulty: 'medium',
            status_complete: false
          }
        }
      end.to change(IndividualTask, :count).by(1)

      individual_task = IndividualTask.last
      expect(individual_task.name).to eq('My Task')
      expect(individual_task.description).to eq('This is my task.')
      expect(individual_task.individual_project).to eq(subscriber.individual_project)
    end

    it 'does not create individual task with invalid values' do
      expect do
        post subscriber_individual_tasks_path, params: {
          individual_task: {
            name: 'My Task'
          }
        }
      end.not_to change(IndividualTask, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'PATCH /subscriber/individual_tasks/:id' do
    let!(:task) do
      IndividualTask.create!(
        name: 'New Task',
        description: 'This is a new task.',
        points: 10,
        due_date: 1.week.from_now,
        reminder_date: 2.days.from_now,
        difficulty: 'medium',
        individual_project: subscriber.individual_project
      )
    end

    it 'updates an individual task with permitted params' do
      expect do
        patch subscriber_individual_task_path(task), params: {
          individual_task: {
            name: 'My Task',
            description: 'This is my task.',
            due_date: 2.week.from_now,
            reminder_date: 4.days.from_now,
            difficulty: 'hard'
          }
        }
      end.not_to change(IndividualTask, :count)
      task.reload
      expect(task.name).to eq('My Task')
      expect(task.description).to eq('This is my task.')
      expect(task.individual_project).to eq(subscriber.individual_project)
      expect(flash[:notice]).to eq('Task updated.')
    end

    it 'does not update individual task with invalid values' do
      expect do
        patch subscriber_individual_task_path(task), params: {
          individual_task: {
            name: 'failed_update',
            due_date: nil
          }
        }
      end.not_to change(IndividualTask, :count)
      task.reload
      expect(task.name).not_to eq('failed_update')
    end

    it 'does not update a non existent task with invalid values' do
      expect do
        patch subscriber_individual_task_path(-1), params: {
          individual_task: {
            name: 'failed_update'
          }
        }
      end.not_to change(IndividualTask, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /subscriber/individual_tasks/:id' do
    let!(:task) do
      IndividualTask.create!(
        name: 'New Task',
        description: 'This is a new task.',
        points: 10,
        due_date: 1.week.from_now,
        reminder_date: 2.days.from_now,
        difficulty: 'medium',
        individual_project: subscriber.individual_project
      )
    end

    it 'deletes an individual task' do
      expect do
        delete subscriber_individual_task_path(task)
      end.to change(IndividualTask, :count).by(-1)
      expect(flash[:notice]).to eq('Task deleted.')
    end

    it 'does not delete a non existent task' do
      expect do
        delete subscriber_individual_task_path(-1)
      end.not_to change(IndividualTask, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /subscriber/individual_tasks/:id/complete' do
    let!(:task) do
      IndividualTask.create!(
        name: 'New Task',
        description: 'This is a new task.',
        points: 10,
        due_date: 1.week.from_now,
        reminder_date: 2.days.from_now,
        difficulty: 'medium',
        individual_project: subscriber.individual_project,
        status_complete: false
      )
    end

    it 'completes an individual task and awards points to the user' do
      expect do
        patch subscriber_complete_individual_task_path(task)
      end.not_to change(IndividualTask, :count)
      task.reload
      subscriber.reload
      expect(task.status_complete).to be(true)
      expect(subscriber.points).to eq(10)
      expect(flash[:notice]).to eq('Task marked as complete.')
    end

    it 'does not complete a non existent task' do
      expect do
        patch subscriber_complete_individual_task_path(-1)
      end.not_to change(IndividualTask, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /subscriber/individual_tasks/:id' do
    let!(:task) do
      IndividualTask.create!(
        name: 'New Task',
        description: 'This is a new task.',
        points: 10,
        due_date: 1.week.from_now,
        reminder_date: 2.days.from_now,
        difficulty: 'medium',
        individual_project: subscriber.individual_project,
        status_complete: false
      )
    end

    it 'shows an individual task' do
      get subscriber_individual_task_path(task)
      expect(response).to redirect_to(subscriber_project_path)
      expect(response).not_to redirect_to(subscriber_individual_task_path(task))
    end
  end
end
