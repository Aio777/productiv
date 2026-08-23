# frozen_string_literal: true

class RadarService
  def self.update_radar_ratings(current_member, radar_ratings_params)
    current_member.radar_ratings.destroy_all
    radar_ratings_params[:radar_ratings].to_h.each do |category_id, rating_value|
      rating = current_member.radar_ratings.create!(
        team_project_member: current_member,
        team_project: current_member.team_project,
        radar_category_id: category_id,
        category_rating: rating_value
      )
      rating.save!
    end
  end

  def self.set_radar_categories(team_project, radar_categories)
    team_project.radar_categories
                .where.not(name: radar_categories)
                .destroy_all

    radar_categories.each do |category_name|
      RadarCategory.find_or_create_by!(
        team_project: team_project,
        name: category_name
      )
    end
  end
end
