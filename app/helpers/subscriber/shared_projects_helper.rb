# frozen_string_literal: true

# app/helpers/subscriber/shared_projects_helper.rb
module Subscriber::SharedProjectsHelper
  THEME_IMAGES = {
    'Mixed Theme' => 'mixed-theme.jpg',
    'Nature Theme' => 'tent-theme.jpg',
    'Office Theme' => 'office-theme.jpg',
    'Forest Theme' => 'forest-theme.jpg'
  }.freeze

  def shared_project_image_options
    THEME_IMAGES.map do |label, filename|
      [label, asset_pack_path("static/images/#{filename}")]
    end
  end

  def shared_project_image_path(filename)
    asset_pack_path("static/images/#{filename}")
  end
end
