require_relative 'spec_helper'
require_relative '../lib/fastlane/plugin/saucectl/helper/config'

describe Fastlane::Saucectl::ConfigGenerator do
  describe 'config generator' do
    before do
      @config = {}
    end

    after do
      FileUtils.rm_rf('.sauce')
    end

    it 'should handle us region' do
      @config[:region] = 'us'
      expect(Fastlane::Saucectl::ConfigGenerator.new(@config).set_region).to eql 'us-west-1'
    end

    it 'should handle us region when not set' do
      expect(Fastlane::Saucectl::ConfigGenerator.new(@config).set_region).to eql 'us-west-1'
    end

    it 'should handle eu region' do
      @config[:region] = 'eu'
      expect(Fastlane::Saucectl::ConfigGenerator.new(@config).set_region).to eql 'eu-central-1'
    end

    it 'should create config.yml file based on user specified virtual device configurations' do
      @config[:region] = 'us'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:clear_data] = true
      @config[:use_test_orchestrator] = true
      @config[:app] = File.expand_path("my-demo-app-android")
      @config[:app_name] = 'myTestApp.apk'
      @config[:test_app] = 'myTestRunner.apk'
      @config[:emulators] = [
        {
          name: "Android GoogleApi Emulator",
          platform_versions: %w[10.0 11.0],
          orientation: 'portrait'
        }
      ]
      Fastlane::Saucectl::ConfigGenerator.new(@config).create
      expect(Dir.exist?('.sauce')).to be_truthy
    end

    it 'should create config.yml file based on user specified android real device configurations' do
      @config[:region] = 'us'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:clear_data] = true
      @config[:use_test_orchestrator] = true
      @config[:app] = File.expand_path("my-demo-app-android")
      @config[:app_name] = 'myTestApp.apk'
      @config[:test_app] = 'myTestRunner.apk'
      @config[:devices] = [
        {
          name: "Some Android Device",
          platform_version: '11.0',
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone'

        },
        {
          id: "android_googleApi_Emulator",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone'
        },
      ]

      Fastlane::Saucectl::ConfigGenerator.new(@config).create
      expect(Dir.exist?('.sauce')).to be_truthy
    end
  end
end
