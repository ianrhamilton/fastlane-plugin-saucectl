require 'fastlane/action'
require 'json'
require 'yaml'
require_relative '../helper/config'

module Fastlane
  module Actions
    class SauceConfigAction < Action
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
                                       type: String,
                                       default_value: 'class'),
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
          FastlaneCore::ConfigItem.new(key: :device_type,
                                       description: "Request that the matching device is a specific type of device. Valid values are: ANY TABLET PHONE any tablet phone",
                                       optional: true,
                                       type: String,
                                       default_value: 'phone'),
          FastlaneCore::ConfigItem.new(key: :private,
                                       description: "Request that the matching device is from your organization's private pool",
                                       optional: true,
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :test_target,
                                       description: "Name of the Xcode test target name",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :test_plan,
                                       description: "Name of the Xcode test plan",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :path_to_tests,
                                       description: "Path to your espresso tests",
                                       optional: true,
                                       type: String,
                                       default_value: "#{Dir.pwd}/app/src/androidTest"),
          FastlaneCore::ConfigItem.new(key: :clear_data,
                                       description: "Clear package data from device (android only)",
                                       optional: true,
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :use_test_orchestrator,
                                       description: "User Android test orchestrator (android only)",
                                       optional: true,
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :virtual_device_name,
                                       description: "The name of the device to emulate for this test suite. To ensure name accuracy, check the list of supported virtual devices. If you are using android emulators for this test suite, this property is REQUIRED",
                                       optional: true,
                                       type: Array,
                                       default_value: ['Android GoogleApi Emulator']),
          FastlaneCore::ConfigItem.new(key: :max_concurrency_size,
                                       description: "Sets the maximum number of suites to execute at the same time. If the test defines more suites than the max, excess suites are queued and run in order as each suite completes",
                                       optional: true,
                                       type: Integer,
                                       default_value: 1),
          FastlaneCore::ConfigItem.new(key: :orientation,
                                       description: "The screen orientation to use while executing this test suite on this virtual device. Valid values are portrait or landscape",
                                       optional: true,
                                       type: String,
                                       default_value: 'portrait')

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
          "sauce_config",
          "sauce_config(
            platform: 'android',
            kind: 'espresso',
            app_path: 'Android.MyCustomApp.apk',
            app_name: 'Android.MyCustomApp.apk',
            test_runner_app: '',
            region: 'eu',
            test_distribution: '',
            is_virtual_device: '',
            virtual_device_names: [],
            platform_versions: [],
            real_devices: [],
            test_target: '',
            test_plan: ''
          )"
        ]
      end
    end
  end
end
