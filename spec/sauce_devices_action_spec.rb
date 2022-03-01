require_relative "spec_helper"
require_relative '../spec/utils/mock_api'

describe Fastlane::Actions::SauceDevicesAction do

  describe 'sauce devices' do

    before do
      mock_api = Saucectl::MockApi.new
      mock_api.available_devices
    end

    it "should return an array of android devices" do
      response = Fastlane::FastFile.new.parse("lane :test do
          sauce_devices({platform: 'android',
                         region: 'eu',
                         sauce_username: 'foo',
                         sauce_access_key: 'bar123'})
        end").runner.execute(:test)
      expect(response.to_s).to include('Samsung_Galaxy_S9_real')
      expect(response.to_s).not_to include('iPhone_12_15_beta_real')
    end

    it "should return an array of ios devices" do
      response = Fastlane::FastFile.new.parse("lane :test do
          sauce_devices({platform: 'ios',
                         region: 'eu',
                         sauce_username: 'foo',
                         sauce_access_key: 'bar123'})
        end").runner.execute(:test)
      expect(response.to_s).not_to include('Samsung_Galaxy_S9_real')
      expect(response.to_s).to include('iPhone_12_15_beta_real')
    end

    it "should return an array of all available devices" do
      response = Fastlane::FastFile.new.parse("lane :test do
          sauce_devices({region: 'eu',
                         sauce_username: 'foo',
                         sauce_access_key: 'bar123'})
        end").runner.execute(:test)
      expect(response.to_s).to include('Samsung_Galaxy_S9_real')
      expect(response.to_s).to include('iPhone_12_15_beta_real')
    end
  end
end
