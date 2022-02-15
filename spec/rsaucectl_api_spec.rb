require_relative 'spec_helper'
require_relative 'utils/mock_api'
require_relative '../lib/fastlane/plugin/rsaucectl/helper/storage'

describe Fastlane::Saucectl::Api do
  describe 'api' do
    before do
      @config = {}
      @config[:username] = 'foo'
      @config[:access_key] = '123'
    end

    it 'should build base url for US region' do
      @config[:region] = 'us'
      api = Fastlane::Saucectl::Api.new(@config)
      response = api.base_url_for_region
      expect(response).to eql('https://api.us-west-1.saucelabs.com')
    end

    it 'should build base url for EU region' do
      @config[:region] = 'eu'
      api = Fastlane::Saucectl::Api.new(@config)
      response = api.base_url_for_region
      expect(response).to eql('https://api.eu-central-1.saucelabs.com')
    end

    it 'should throw and error when invalid region is set' do
      @config[:region] = 'fail'

      expect { Fastlane::Saucectl::Api.new(@config).base_url_for_region }.
        to raise_error(StandardError, 'fail is an invalid region ❌. Available: ["us", "eu"]')
    end

    it 'should get sauce labs apps' do
      @config[:region] = 'eu'
      @config[:platform] = 'android'
      @config[:app_name] = 'test.apk'
      mock_api = Saucectl::MockApi.new
      mock_api.with(:get,
                    'storage/files?kind=android&q=test.apk',
                    default_header,
                    'apps_response.json',
                    200)

      api = Fastlane::Saucectl::Storage.new(@config)
      response = api.retrieve_all_apps
      expect(response.code).to eql('200')
    end

    it 'should delete app by user specified app id' do
      @config[:region] = 'eu'
      @config[:platform] = 'android'
      @config[:app_name] = 'test.apk'
      @config[:app_id] = '1235-1235-1235-1235-1235'

      mock_api = Saucectl::MockApi.new
      mock_api.with(:get,
                    'storage/files?kind=android&q=test.apk',
                    default_header,
                    'apps_response.json',
                    200)

      mock_api.with(:delete,
                    'storage/files/1235-1235-1235-1235-1235',
                    delete_header,
                    'delete_by_id_response.json',
                    200)

      api = Fastlane::Saucectl::Storage.new(@config)
      response = api.delete_app_with_file_id
      expect(response.code).to eql('200')
    end

    it 'should delete sauce labs app by group_id' do
      @config[:region] = 'eu'
      @config[:platform] = 'android'
      @config[:app_name] = 'test.apk'
      @config[:group_id] = '123456789'

      mock_api = Saucectl::MockApi.new
      mock_api.with(:delete,
                    "storage/files/#{@config[:group_id]}",
                    delete_header,
                    'delete_response.json',
                    200)

      api = Fastlane::Saucectl::Storage.new(@config)
      response = api.delete_all_apps_for_group_id
      expect(response.code).to eql('200')
    end

    it 'should upload applications app' do
      @config[:region] = 'eu'
      @config[:platform] = 'android'
      @config[:app_name] = 'test.apk'
      @config[:app_path] = "#{__dir__}/utils/test.apk"

      mock_api = Saucectl::MockApi.new
      mock_api.with(:post,
                    'storage/upload',
                    upload_header,
                    'apps_response.json',
                    200)

      api = Fastlane::Saucectl::Storage.new(@config)
      response = api.upload_app
      expect(response.code).to eql('200')
    end

    it 'should get available real devices' do
      @config[:region] = 'eu'
      @config[:platform] = 'android'

      mock_api = Saucectl::MockApi.new
      mock_api.available_devices

      api = Fastlane::Saucectl::Api.new(@config)
      response = api.available_devices
      expect(response.code).to eql('200')
    end

    it 'should get available ios devices' do
      @config[:region] = 'eu'
      @config[:platform] = 'android'

      mock_api = Saucectl::MockApi.new
      mock_api.available_devices

      api = Fastlane::Saucectl::Api.new(@config)
      response = api.fetch_ios_devices

      expect(response.to_s).to include('iPhone_12_15_beta_real')
      expect(response.to_s).not_to include('Samsung_Galaxy_S9_real')
    end

    it 'should get available android devices' do
      @config[:region] = 'eu'
      @config[:platform] = 'android'

      mock_api = Saucectl::MockApi.new
      mock_api.available_devices

      api = Fastlane::Saucectl::Api.new(@config)
      response = api.fetch_android_devices

      expect(response.to_s).to include('Samsung_Galaxy_S9_real')
      expect(response.to_s).not_to include('iPhone_12_15_beta_real')
    end
  end
end
