# frozen_string_literal: true

class Subscriber::AiMessagesController < Subscriber::BaseController
  def create
    task_name = params[:task_name].to_s.strip
    description = params[:description].to_s.strip

    return render json: { error: 'task_name is required' }, status: :bad_request if task_name.empty?

    prompt = build_prompt(task_name:, description:)

    breakdown = Ai::GeminiClient.generate_text(prompt)

    if params[:task_type] == 'individual'
      Metrics::MetricTrackerService.new(ahoy).track_ai_breakdown_individual_task(params[:user_id], request)
    elsif params[:task_type] == 'shared'
      Metrics::MetricTrackerService.new(ahoy).track_ai_breakdown_shared_task(params[:user_id], request)
    end

    render json: { breakdown: breakdown }
  rescue Ai::GeminiClient::Error => e
    Sentry.capture_exception(e)
    render json: { error: e.message }, status: :bad_gateway
  rescue StandardError => e
    Sentry.capture_exception(e)
    Rails.logger.error("[AI] #{e.class}: #{e.message}\n#{e.backtrace&.first(10)&.join("\n")}")
    render json: { error: 'Unexpected error' }, status: :internal_server_error
  end

  def fallback
    task_name = params[:task_name].to_s.strip
    description = params[:description].to_s.strip

    return render json: { error: 'task_name is required' }, status: :bad_request if task_name.empty?

    breakdown = Ai::FallbackTaskBreakdown.for(
      task_name: task_name,
      description: description
    )

    if breakdown.present?
      render json: { breakdown: breakdown, fallback: true }
    else
      render json: { error: 'No fallback breakdown available' }, status: :not_found
    end
  end

  private

  def build_prompt(task_name:, description:)
    parts = []
    parts << "Task name: #{task_name}"
    parts << "Description: #{description}" if description.present?
    parts << ''
    parts << 'Break this task into 5 to 8 small, practical subtasks.'
    parts << 'Each step should be short, specific, and immediately actionable.'
    parts << 'Prefer concrete actions over broad long-term plans.'
    parts << 'Return a concise numbered list only.'
    parts << 'Do not use markdown, asterisks, or bold formatting.'
    parts << 'Do not ask follow-up questions.'
    parts.join("\n")
  end
end
