# spec/services/points_service_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PointsService, type: :service do
  describe '.calc_individual_task_points' do
    context 'when difficulty is easy and no due_date is provided' do
      let(:params) do
        {
          difficulty: 'easy',
          due_date: nil
        }
      end

      it 'returns the base points only' do
        expect(described_class.calc_individual_task_points(params)).to eq(20)
      end
    end

    context 'when difficulty is medium' do
      let(:params) do
        {
          difficulty: 'medium',
          due_date: nil
        }
      end

      it 'adds difficulty points' do
        expect(described_class.calc_individual_task_points(params)).to eq(35)
      end
    end

    context 'when difficulty is hard' do
      let(:params) do
        {
          difficulty: 'hard',
          due_date: nil
        }
      end

      it 'adds difficulty points' do
        expect(described_class.calc_individual_task_points(params)).to eq(55)
      end
    end

    context 'when due date is within 1 day' do
      let(:params) do
        {
          difficulty: 'easy',
          due_date: Time.current + 1.day,
          created_at: Time.current
        }
      end

      it 'adds 30 urgency points' do
        expect(described_class.calc_individual_task_points(params)).to eq(50)
      end
    end

    context 'when due date is within 2 to 3 days' do
      let(:params) do
        {
          difficulty: 'easy',
          due_date: Time.current + 3.days,
          created_at: Time.current
        }
      end

      it 'adds 20 urgency points' do
        expect(described_class.calc_individual_task_points(params)).to eq(40)
      end
    end

    context 'when due date is within 4 to 7 days' do
      let(:params) do
        {
          difficulty: 'easy',
          due_date: Time.current + 7.days,
          created_at: Time.current
        }
      end

      it 'adds 10 urgency points' do
        expect(described_class.calc_individual_task_points(params)).to eq(30)
      end
    end

    context 'when due date is more than 7 days away' do
      let(:params) do
        {
          difficulty: 'easy',
          due_date: Time.current + 10.days,
          created_at: Time.current
        }
      end

      it 'does not add urgency points' do
        expect(described_class.calc_individual_task_points(params)).to eq(20)
      end
    end

    context 'when both difficulty and urgency apply' do
      let(:params) do
        {
          difficulty: 'hard',
          due_date: Time.current + 2.days,
          created_at: Time.current
        }
      end

      it 'adds both difficulty and urgency points' do
        expect(described_class.calc_individual_task_points(params)).to eq(75)
      end
    end
  end

  describe '.calc_team_project_task_points' do
    let(:task) { instance_double(TeamProjectTask, assigned_members: assigned_members) }

    context 'when there are no assigned members' do
      let(:assigned_members) { [] }
      let(:params) do
        {
          difficulty: 'medium',
          due_date: Time.current + 3.days,
          created_at: Time.current
        }
      end

      it 'does not apply a multiplier' do
        expect(described_class.calc_team_project_task_points(params, task)).to eq(55)
      end
    end

    context 'when there are 2 assigned members' do
      let(:assigned_members) { double(count: 2, any?: true) }
      let(:params) do
        {
          difficulty: 'easy',
          due_date: Time.current + 3.days,
          created_at: Time.current
        }
      end

      it 'applies the 1.5 multiplier' do
        expect(described_class.calc_team_project_task_points(params, task)).to eq(60)
      end
    end

    context 'when there are 3 assigned members' do
      let(:assigned_members) { double(count: 3, any?: true) }
      let(:params) do
        {
          difficulty: 'easy',
          due_date: Time.current + 3.days,
          created_at: Time.current
        }
      end

      it 'applies the 1.75 multiplier' do
        expect(described_class.calc_team_project_task_points(params, task)).to eq(70)
      end
    end

    context 'when there are 4 or more assigned members' do
      let(:assigned_members) { double(count: 4, any?: true) }
      let(:params) do
        {
          difficulty: 'easy',
          due_date: Time.current + 3.days,
          created_at: Time.current
        }
      end

      it 'applies the 2x multiplier' do
        expect(described_class.calc_team_project_task_points(params, task)).to eq(80)
      end
    end

    context 'when the multiplied result is a float' do
      let(:assigned_members) { double(count: 2, any?: true) }
      let(:params) do
        {
          difficulty: 'medium',
          due_date: nil
        }
      end

      it 'returns an integer' do
        # 20 + 15 = 35, 35 * 1.5 = 52.5, to_i => 52
        expect(described_class.calc_team_project_task_points(params, task)).to eq(52)
      end
    end
  end

  describe '.calc_points_for_assignment' do
    let(:task) do
      instance_double(
        TeamProjectTask,
        difficulty: difficulty,
        due_date: due_date,
        assigned_members: assigned_members,
        created_at: created_at
      )
    end

    let(:created_at) { Time.current }

    context 'when task has no due date and no assigned members' do
      let(:difficulty) { 'easy' }
      let(:due_date) { nil }
      let(:assigned_members) { [] }

      it 'returns base points' do
        expect(described_class.calc_points_for_assignment(task)).to eq(20)
      end
    end

    context 'when task has difficulty, urgency, and member multiplier' do
      let(:difficulty) { 'hard' }
      let(:due_date) { Time.current + 1.day }
      let(:assigned_members) { double(count: 3, any?: true) }

      it 'calculates points from task attributes' do
        # 20 + 35 + 30 = 85
        # 85 * 1.75 = 148.75
        # to_i => 148
        expect(described_class.calc_points_for_assignment(task)).to eq(148)
      end
    end
  end
end
