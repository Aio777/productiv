require 'webmock/rspec'
WebMock.allow_net_connect!

VCR.configure do |config|
  config.cassette_library_dir = "#{::Rails.root}/spec/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.allow_http_connections_when_no_cassette = true
  config.configure_rspec_metadata!
end
