# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples_for 'request_extendable' do
  describe '#add_ip_to_request_path_parameters' do
    it "adds the correct IP address to the request's path parameters" do
      controller.add_ip_to_request_path_parameters(request.path_parameters, '35.242.177.6')
      expect(request.path_parameters['ip']).to eq('35.242.177.6')
    end
  end

  describe '#add_location_to_request_path_parameters' do
    it "adds the location for a valid IP address to the request's path parameters" do
      request.path_parameters['ip'] = '35.242.177.6'

      VCR.use_cassette('geocoder/35.242.177.6') do
        controller.add_location_to_request_path_parameters(request.path_parameters)
        expect(request.path_parameters['country']).to eq('GB')
        expect(request.path_parameters['city']).to eq('London')
      end
    end

    it 'adds no location for a bogon IP address' do
      request.path_parameters['ip'] = '127.0.0.1'

      VCR.use_cassette('geocoder/127.0.0.1') do
        controller.add_location_to_request_path_parameters(request.path_parameters)
        expect(request.path_parameters['country']).to eq(nil)
        expect(request.path_parameters['city']).to eq(nil)
      end
    end

    it 'adds no location for an invalid IP address' do
      stub_request(
        :get,
        'https://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=12.345.678.9'
      ).to_return_json(body: {})
      request.path_parameters['ip'] = '12.345.678.9'

      controller.add_location_to_request_path_parameters(request.path_parameters)
      expect(request.path_parameters['country']).to eq(nil)
      expect(request.path_parameters['city']).to eq(nil)
    end
  end

  describe '#add_task_points_to_request_path_parameters' do
    it "adds the correct task points to the request's path parameters" do
      controller.add_task_points_to_request_path_parameters(request.path_parameters, '15')
      expect(request.path_parameters['task_points']).to eq('15')
    end
  end
end
