require 'capybara/rspec'
Capybara.app_host = 'http://localhost:3000'
RSpec.configure do |config|
  config.include Capybara::DSL
end