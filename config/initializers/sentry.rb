# frozen_string_literal: true

Sentry.init do |config|
  # Sentry is only enabled when the dsn is set.
  config.dsn = 'https://90f382158f660caf11cf3581c11f62aa@sentry.shefcompsci.org.uk/2' unless Rails.env.development? || Rails.env.test?
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.before_send = ->(event, _hint) { ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters).filter(event.to_hash) }
  config.excluded_exceptions += [
    'ActionController::BadRequest',
    'ActionController::UnknownFormat',
    'ActionController::UnknownHttpMethod',
    'ActionDispatch::Http::MimeNegotiation::InvalidType',
    'CanCan::AccessDenied',
    'Mime::Type::InvalidMimeType',
    'Rack::QueryParser::InvalidParameterError',
    'Rack::QueryParser::ParameterTypeError',
    'SystemExit',
    'URI::InvalidURIError'
  ]
end
