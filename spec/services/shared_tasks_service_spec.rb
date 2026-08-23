# spec/services/shared_tasks_service_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SharedTasksService, type: :service do
  describe '.find_team_project' do
    let(:team_project) { FactoryBot.create(:team_project, name: 'Test Project') }
    let(:params) { { team_project_id: team_project.id } }
    let(:service) { instance_double(described_class) }

    it 'finds the team project if it exists' do
      team_project = described_class.find_team_project(params)
      expect(team_project.name).to eq('Test Project')
    end
  end

  describe '.task_params' do
    context 'when team_project_task params are provided' do
      let(:params) do
        ActionController::Parameters.new(
          team_project_task: {
            team_project_id: 1,
            points: 5,
            name: 'Test task',
            description: 'Some description',
            due_date: '2026-04-10',
            reminder_date: '2026-04-09',
            difficulty: 'medium',
            status_complete: false
          }
        )
      end

      it 'permits the correct attributes' do
        result = described_class.task_params(params)
        expect(result.to_h.symbolize_keys).to eq(
          team_project_id: 1,
          points: 5,
          name: 'Test task',
          description: 'Some description',
          due_date: '2026-04-10',
          reminder_date: '2026-04-09',
          difficulty: 'medium',
          status_complete: false
        )
      end
    end

    context 'when shared_task params are provided' do
      let(:params) do
        ActionController::Parameters.new(
          shared_task: {
            team_project_id: 2,
            points: 8,
            name: 'Shared task',
            description: 'Shared description',
            due_date: '2026-04-11',
            reminder_date: '2026-04-10',
            difficulty: 'hard',
            status_complete: true
          }
        )
      end

      it 'permits the correct attributes' do
        result = described_class.task_params(params)

        expect(result.to_h.symbolize_keys).to eq(
          team_project_id: 2,
          points: 8,
          name: 'Shared task',
          description: 'Shared description',
          due_date: '2026-04-11',
          reminder_date: '2026-04-10',
          difficulty: 'hard',
          status_complete: true
        )
      end
    end

    context 'when neither team_project_task nor shared_task is provided' do
      let(:params) do
        ActionController::Parameters.new({})
      end

      it 'raises ParameterMissing' do
        expect do
          described_class.task_params(params)
        end.to raise_error(
          ActionController::ParameterMissing,
          'param is missing or the value is empty or invalid: team_project_task or shared_task'
        )
      end
    end
  end

  describe '.complete_and_assign_user_points' do
    let!(:team_project) { create(:team_project) }
    let!(:task) { create(:team_project_task, team_project: team_project, status_complete: false) }

    context 'when there are no assigned members' do
      it 'returns false' do
        result = described_class.complete_and_assign_user_points(task, 10)

        expect(result).to be(false)
      end
    end

    context 'when assigned members exist' do
      let!(:user1) { create(:user, points: 3) }
      let!(:user2) { create(:user, points: 7) }

      let!(:member1) { create(:team_project_member, team_project: team_project, user: user1, points: 1) }
      let!(:member2) { create(:team_project_member, team_project: team_project, user: user2, points: 4) }

      before do
        task.assigned_members << [member1, member2]
      end

      it 'marks the task as complete' do
        described_class.complete_and_assign_user_points(task, 10)

        expect(task.reload.status_complete).to be(true)
      end

      it 'distributes points evenly to members' do
        described_class.complete_and_assign_user_points(task, 10)

        expect(member1.reload.points).to eq(6)
        expect(member2.reload.points).to eq(9)
      end

      it 'distributes points evenly to users' do
        described_class.complete_and_assign_user_points(task, 10)

        expect(user1.reload.points).to eq(8)
        expect(user2.reload.points).to eq(12)
      end

      it 'returns true' do
        result = described_class.complete_and_assign_user_points(task, 10)

        expect(result).to be(true)
      end
    end

    context 'when points need rounding up' do
      let!(:user1) { create(:user, points: 0) }
      let!(:user2) { create(:user, points: 0) }

      let!(:member1) { create(:team_project_member, team_project: team_project, user: user1, points: 0) }
      let!(:member2) { create(:team_project_member, team_project: team_project, user: user2, points: 0) }

      before do
        task.assigned_members << [member1, member2]
      end

      it 'uses ceil when splitting points' do
        described_class.complete_and_assign_user_points(task, 5)

        expect(member1.reload.points).to eq(3)
        expect(member2.reload.points).to eq(3)
        expect(user1.reload.points).to eq(3)
        expect(user2.reload.points).to eq(3)
      end
    end

    context 'when an error occurs during update' do
      let!(:user) { create(:user, points: 0) }
      let!(:member) { create(:team_project_member, team_project: team_project, user: user, points: 0) }

      before do
        task.assigned_members << member

        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(TeamProjectMember)
          .to receive(:update!)
          .and_raise(ActiveRecord::ActiveRecordError)
        # rubocop:enable RSpec/AnyInstance
      end

      it 'returns false' do
        result = described_class.complete_and_assign_user_points(task, 10)

        expect(result).to be(false)
      end

      it 'does not persist changes (transaction rollback)' do
        described_class.complete_and_assign_user_points(task, 10)

        expect(task.reload.status_complete).to be(false)
        expect(member.reload.points).to eq(0)
        expect(user.reload.points).to eq(0)
      end
    end
  end
end
