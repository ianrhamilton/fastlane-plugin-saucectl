require 'fastlane/action'
require 'json'
require 'yaml'
require_relative '../helper/config'

module Fastlane
  module Actions
    class SauceLabsConfigAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")

      def self.run(params)
        Fastlane::Saucectl::ConfigGenerator.new(params).create
      end

      def self.description
        "Create SauceLabs configuration file for test execution based on given parameters"
      end

      def self.details
        "Create SauceLabs configuration file for test execution based on given parameters"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :platform,
                                       description: "application under test platform (ios or android)",
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['platform_error']) if value.to_s.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :kind,
                                       description: "Specifies which framework is associated with the automation tests configured in this specification (xcuitest & espresso)",
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['platform_error']) if value.to_s.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_path,
                                       description: "Path to the application under test",
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['app_path_error']) unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       description: "Name of your application under test",
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['app_name_error']) unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :test_runner_app,
                                       description: "Name of your test runner application",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['test_runner_app_error']) unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :region,
                                       description: "Data Center region (us or eu), set using: region: 'eu'",
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['region_error'].gsub!('$region', value)) unless @messages['supported_regions'].include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :concurrency,
                                       description: "Controls how many suites are executed at the same time",
                                       optional: true,
                                       type: Integer,
                                       default_value: 1),
          FastlaneCore::ConfigItem.new(key: :retries,
                                       description: "Sets the number of times to retry a failed suite",
                                       optional: true,
                                       type: Integer,
                                       default_value: 0),
          FastlaneCore::ConfigItem.new(key: :test_distribution,
                                       description: "Test distribution method",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :is_virtual_device,
                                       description: "Is device under test a an emulator (support for android only)",
                                       optional: true,
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :virtual_device_names,
                                       description: "Virtual devices in which you would like to test your applications on",
                                       optional: true,
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :platform_versions,
                                       description: "Platform version of the device or virtual device you wish to test your application on",
                                       optional: true,
                                       type: Array,
                                       default_value: ['11.0']),
          FastlaneCore::ConfigItem.new(key: :real_devices,
                                       description: "Array of devices to execute tests on",
                                       optional: true,
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :test_target,
                                       description: "Name of the Xcode test target name",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :test_plan,
                                       description: "Name of the Xcode test plan",
                                       optional: true,
                                       type: String)
        ]
      end

      def self.authors
        ["Ian Hamilton"]
      end

      def self.category
        :testing
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end

      def self.example_code
        [
          "upload_to_saucelabs",
          "upload_to_saucelabs(
            platform: 'android',
            app_path: 'app/build/outputs/apk/debug/app-debug.apk',
            app_name: 'Android.MyCustomApp.apk',
            app_description: 'description of my app'
            region: 'eu',
            sauce_username: 'sauce username',
            sauce_access_key: 'sauce api name'
          )"
        ]
      end
    end
  end
end
