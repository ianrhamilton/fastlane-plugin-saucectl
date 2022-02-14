# frozen_string_literal: true

module Saucectl
  # helper class for mocking api's in unit tests
  class MockApi
    def with(type, path, headers, file, response_code)
      stub_request(type, "https://api.eu-central-1.saucelabs.com/v1/#{path}")
        .with(
          headers: headers
        )
        .to_return(status: response_code, body: File.new("#{__dir__}/mocks/#{file}"), headers: {})
    end

    def download
      stub_request(:get, 'https://saucelabs.github.io/saucectl/install')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: '', headers: {})
    end

    def available_devices
      stub_request(:get, 'https://api.eu-central-1.saucelabs.com/v1/rdc/devices/available')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Basic Og==',
            'Host' => 'api.eu-central-1.saucelabs.com',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: File.new("#{__dir__}/mocks/devices.json"), headers: {})
    end
  end
end
