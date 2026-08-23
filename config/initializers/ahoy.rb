# frozen_string_literal: true

class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    data[:accept_language] = request.headers['Accept-Language']
    super(data)
  end
end

# set to true for JavaScript tracking
Ahoy.api = true

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = true

# custom configurations
Ahoy.visit_duration = 30.minutes
Ahoy.visitor_duration = 1.year
Ahoy.cookie_options = { expires: 1.year }
Ahoy.mask_ips = true

Ahoy.exclude_method = lambda do |controller, _request|
  controller.is_a?(Admin::BaseController)
end
