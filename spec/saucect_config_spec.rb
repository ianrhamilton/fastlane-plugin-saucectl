require_relative 'spec_helper'
require_relative '../lib/fastlane/plugin/rsaucectl/helper/config'

describe Fastlane::Saucectl::ConfigGenerator do
  describe 'config generator' do
    before do
      @config = {}
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
    end

    after do
      # FileUtils.rm_rf('.sauce')
    end

    it 'should create config.yml file based on user specified virtual device configurations' do
      @config[:test_distribution] = 'shard'
      @config[:is_virtual_device] = true
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:region] = 'eu'
      @config[:shards] = 2
      @config[:platform_versions] = ['11.0']
      @config[:virtual_device_name] = ['FooBar']
      File.open('config.yml', 'w') { |f| YAML.dump(@config, f) }

      Fastlane::Saucectl::ConfigGenerator.new(@config).create
      origin_folder = File.expand_path("../", "#{__dir__}")
      expect(File.exist?("#{origin_folder}/.sauce/config.yml")).to be_truthy
    end

    it 'should create config.yml file based on user specified android real device configurations' do
      @config[:test_distribution] = 'package'
      @config[:is_virtual_device] = false
      @config[:real_devices] = ['device one', 'device_two', 'device three', 'device_four']
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:region] = 'eu'
      File.open('config.yml', 'w') { |f| YAML.dump(@config, f) }

      Fastlane::Saucectl::ConfigGenerator.new(@config).create
      origin_folder = File.expand_path("../", "#{__dir__}")
      expect(File.exist?("#{origin_folder}/.sauce/config.yml")).to be_truthy
    end

    it 'should create config.yml file based on user specified ios real device configurations' do
      @config[:test_distribution] = 'shard'
      @config[:real_devices] = ['device one', 'device_two']
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:region] = 'eu'
      File.open('config.yml', 'w') { |f| YAML.dump(@config, f) }

      Fastlane::Saucectl::ConfigGenerator.new(@config).create
      origin_folder = File.expand_path("../", "#{__dir__}")
      expect(File.exist?("#{origin_folder}/.sauce/config.yml")).to be_truthy
    end
  end
end
