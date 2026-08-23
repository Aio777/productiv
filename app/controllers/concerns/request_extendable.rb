# frozen_string_literal: true

module RequestExtendable
  extend ActiveSupport::Concern

  def add_ip_to_request_path_parameters(path_parameters, ip)
    path_parameters['ip'] = ip
  end

  def add_location_to_request_path_parameters(path_parameters)
    result = Geocoder.search(path_parameters['ip'])

    if result.first.nil?
      path_parameters['country'] = nil
      path_parameters['city'] = nil
    else
      path_parameters['country'] = result.first.country
      path_parameters['city'] = result.first.city
    end
  end

  def add_task_points_to_request_path_parameters(path_parameters, task_points)
    path_parameters['task_points'] = task_points
  end
end
