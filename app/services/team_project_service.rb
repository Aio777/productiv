# frozen_string_literal: true

class TeamProjectService
  def self.process_params(params)
    new(params).call
  end

  def self.update_team_members(team_project, team_project_params)
    lead = team_project.team_lead

    SharedInviteService.create_shared_invites_on_update(lead, team_project, team_project_params)
  end

  def self.configure_team_members(team_project, team_project_params)
    remove_member_ids = Array(team_project_params[:remove_member_ids]).reject(&:blank?).map(&:to_i)

    remove_team_members(team_project, remove_member_ids) if remove_member_ids.any?

    return unless team_project_params[:invite_emails].present?

    update_team_members(team_project, team_project_params)
  end

  def self.update_member_radar_ratings(current_member, radar_ratings_params)
    RadarService.update_radar_ratings(current_member, radar_ratings_params)
  end

  def self.update_member_leaderboard_visibility(current_member, params)
    hide = params[:hide_leaderboard] == '1'
    current_member.update!(leaderboard_visibility: !hide)
  end

  def self.create_new_team_project(team_project, team_lead, team_project_params)
    TeamProjectMember.create!(
      team_project: team_project,
      user: team_lead,
      role: 'team_lead',
      joined_at: Time.current
    )
    lead = team_project.team_lead

    SharedInviteService.create_shared_invites_on_create(lead, team_project, team_project_params)
  end

  def self.set_radar_categories(team_project_params, team_project)
    radar_categories = Array(team_project_params[:radar_categories])
                       .map(&:strip)
                       .reject(&:blank?)

    raise ArgumentError, 'You must enter unique Skill Types' if radar_categories.uniq!

    invalid_radar_length = radar_categories.length < 3 || radar_categories.length > 5
    if !radar_categories.empty? && invalid_radar_length
      raise ArgumentError, 'You must enter either 0 or between 3 and 5 categories'
    end

    RadarService.set_radar_categories(team_project, radar_categories)
  end

  def self.remove_team_members(team_project, remove_member_ids)
    team_project.team_project_members
                .where(id: remove_member_ids)
                .where.not(role: 'team_lead')
                .destroy_all
  end

  def initialize(params)
    @params = params
  end

  def call
    sanitize_image_path
    normalize_invite_emails
    normalize_radar_categories
    @params
  end

  private

  def sanitize_image_path
    return unless @params[:image_path].present?

    @params[:image_path] = File.basename(@params[:image_path])
                               .sub(/-[a-f0-9]{20,}\./, '.')
  end

  def normalize_invite_emails
    return unless @params[:invite_emails]

    @params[:invite_emails] = @params[:invite_emails]
                              .map(&:strip)
                              .reject(&:blank?)
                              .map(&:downcase)
                              .uniq
  end

  def normalize_radar_categories
    return unless @params[:radar_categories]

    @params[:radar_categories] = @params[:radar_categories]
                                 .map(&:strip)
                                 .reject(&:blank?)
  end
end
