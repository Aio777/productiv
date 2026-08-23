# frozen_string_literal: true

class PointsService
  class << self
    def calc_individual_task_points(params)
      base_points = 20
      base_points = add_difficulty_points(base_points, params)
      base_points = add_urgency_points(base_points, params)
      base_points.to_i
    end

    def calc_team_project_task_points(params, task)
      base_points = 20
      base_points = add_difficulty_points(base_points, params)
      base_points = add_urgency_points(base_points, params)
      base_points = add_member_points_multiplier(base_points, task)
      base_points.to_i
    end

    def calc_points_for_assignment(task)
      params = {
        difficulty: task.difficulty,
        due_date: task.due_date,
        assigned_members: task.assigned_members,
        created_at: task.created_at
      }

      base_points = 20
      base_points = add_difficulty_points(base_points, params)
      base_points = add_urgency_points(base_points, params)
      base_points = add_member_points_multiplier(base_points, task)
      base_points.to_i
    end

    private

    def add_difficulty_points(base_points, params)
      case params[:difficulty]
      when 'medium'
        base_points += 15
      when 'hard'
        base_points += 35
      end
      base_points
    end

    def add_urgency_points(base_points, params)
      case calculate_days_to_due(params)
      when 0..1
        base_points += 30
      when 2..3
        base_points += 20
      when 4..7
        base_points += 10
      end
      base_points
    end

    def add_member_points_multiplier(base_points, task)
      if task.assigned_members.any?
        case task.assigned_members.count
        when 2
          base_points *= 1.5
        when 3
          base_points *= 1.75
        when 4..Float::INFINITY
          base_points *= 2
        end
      end
      base_points
    end

    def calculate_days_to_due(params)
      return nil if params[:due_date].blank?

      created_at = params[:created_at] || Time.current
      (params[:due_date].to_date - created_at.to_date).to_i
    end
  end
end
