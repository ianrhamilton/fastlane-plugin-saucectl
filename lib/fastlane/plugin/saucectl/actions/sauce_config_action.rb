require 'fastlane/action'
require 'json'
require 'yaml'
require_relative '../helper/config'
require_relative '../helper/runner'

module Fastlane
  module Actions
    class SauceConfigAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")

      def self.run(params)
        if params[:platform].eql?('android')
          UI.user_error!("❌ For android platform you must specify devices or emulators under test in order to execute tests") if params[:emulators].nil? && params[:devices].nil?
        else
          if params[:emulators]
            UI.user_error!("❌ Sauce Labs platform does not currently support virtual device execution for ios apps")
          end
          UI.user_error!("❌ For ios platform you must specify devices under test in order to execute tests") if params[:devices].nil?
        end

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
          FastlaneCore::ConfigItem.new(key: :app,
                                       description: "The path to the app",
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['app_name_error']) unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :test_app,
                                       description: "The path to the testing app",
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
          FastlaneCore::ConfigItem.new(key: :test_class,
                                       description: "Array of tests to execute",
                                       optional: true,
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :size,
                                       description: "Instructs saucectl to run only tests that are annotated with the matching size value i.e @SmallTest, @MediumTest or @LargeTest. Valid values are small, medium, or large. You may only specify one value for this property",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :emulators,
                                       description: "The parent property that defines details for running this suite on virtual devices using an emulator",
                                       optional: true,
                                       type: Array,
                                       verify_block: proc do |emulators|
                                         emulators.each do |emulator|
                                           if emulator.class != Hash
                                             UI.user_error!("Each emulator must be represented by a Hash object, #{emulator.class} found")
                                           end
                                           verify_device_property(emulator, :name)
                                           set_default_property(emulator, :orientation, 'portrait')
                                           verify_device_property(emulator, :platform_versions)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :devices,
                                       description: "The parent property that defines details for running this suite on real devices",
                                       optional: true,
                                       type: Array,
                                       verify_block: proc do |devices|
                                         devices.each do |device|
                                           if device.class != Hash
                                             UI.user_error!("Each device must be represented by a Hash object, #{device.class} found")
                                           end
                                           verify_optional_device_props(device)
                                           set_default_property(device, :orientation, 'portrait')
                                           set_default_property(device, :device_type, 'phone')
                                           set_default_property(device, :private, true)
                                           set_default_property(device, :carrier_connectivity, false)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :name,
                                       description: "The name of the device or emulator",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :id,
                                       description: "The id of the device",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :platform_versions,
                                       description: "Platform versions of the virtual device you wish to test your application on: Virtual Device only",
                                       optional: true,
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :platform_version,
                                       description: "Platform version of the real device you wish to test your application on: Real device only",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :orientation,
                                       description: "The orientation of the device. Default: portrait",
                                       optional: true,
                                       type: String,
                                       default_value: 'portrait'),
          FastlaneCore::ConfigItem.new(key: :device_type,
                                       description: "Request that the matching device is a specific type of device. Valid values are: ANY TABLET PHONE any tablet phone",
                                       optional: true,
                                       type: String,
                                       default_value: 'phone'),
          FastlaneCore::ConfigItem.new(key: :private,
                                       description: "Request that the matching device is from your organization's private pool",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :carrier_connectivity,
                                       description: "Request that the matching device is also connected to a cellular network",
                                       optional: true,
                                       is_string: false),
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
          FastlaneCore::ConfigItem.new(key: :max_concurrency_size,
                                       description: "Sets the maximum number of suites to execute at the same time. If the test defines more suites than the max, excess suites are queued and run in order as each suite completes",
                                       optional: true,
                                       type: Integer,
                                       default_value: 1)
        ]
      end

      def self.verify_device_property(device, property)
        UI.user_error!("Each device must have #{property} property") unless device.key?(property)
      end

      def self.verify_optional_device_props(device)
        unless device.key?(:name) || device.key?(:id)
          UI.user_error!("Real devices must have a device name or device id")
        end
      end

      private_class_method :verify_device_property

      def self.set_default_property(device, property, default)
        unless device.key?(property)
          device[property] = default
        end
      end

      private_class_method :set_default_property

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
          "sauce_config({platform: 'android',
                         kind: 'espresso',
                         app: 'path/to/myTestApp.apk',
                         test_app: 'path/to/myTestRunner.apk',
                         path_to_tests: 'path/to/app/src/androidTest',
                         region: 'eu',
                         emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: %w[10.0 11.0], orientation: 'portrait'}]
                       })",
          "sauce_config({platform: 'android',
                         kind: 'espresso',
                         app: 'path/to/myTestApp.apk',
                         test_app: 'path/to/myTestRunner.apk',
                         path_to_tests: 'path/to/app/src/androidTest',
                         region: 'eu',
                         test_distribution: 'testCase',
                         devices: [ {name: 'RDC One', orientation: 'portrait', platform_version: '11.0'}]
          })",
          "sauce_config({platform: 'android',
                         kind: 'espresso',
                         app: 'path/to/myTestApp.apk',
                         test_app: 'path/to/myTestRunner.apk',
                         path_to_tests: 'path/to/app/src/androidTest',
                         region: 'eu',
                         test_distribution: 'shard',
                         devices: [ {name: 'RDC One', orientation: 'portrait', platform_version: '11.0'}]
          })",
          "sauce_config({platform: 'ios',
                         kind: 'xcuitest',
                         app: 'path/to/MyTestApp.ipa',
                         test_app: 'path/to/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_target: 'MyDemoAppUITests'
          })",
          "sauce_config({platform: 'ios',
                         kind: 'xcuitest',
                         app: 'path/to/MyTestApp.ipa',
                         test_app: 'path/to/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_target: 'MyDemoAppUITests',
                         test_distribution: 'shard',
          })",
          " sauce_config({platform: 'ios',
                         kind: 'xcuitest',
                         app: 'path/to/MyTestApp.ipa',
                         test_app: 'path/to/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_target: 'MyDemoAppUITests',
                         test_distribution: 'testCase'
          })",
          "sauce_config({platform: 'ios',
                         kind: 'xcuitest',
                         app: 'path/to/MyTestApp.ipa',
                         test_app: 'path/to/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_plan: 'EnabledUITests',
                         test_distribution: 'shard'
          })",
          "sauce_config({platform: 'ios',
                         kind: 'xcuitest',
                         app: 'path/to/MyTestApp.ipa',
                         test_app: 'path/to/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_plan: 'UITests'
          })",
          "sauce_config({platform: 'android',
                         kind: 'espresso',
                         app: 'path/to/myTestApp.apk',
                         test_app: 'path/to/myTestRunner.apk',
                         path_to_tests: 'path/to/app/src/androidTest',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}],
                         test_class: ['com.some.package.testing.SomeClassOne', 'com.some.package.testing.SomeClassTwo', 'com.some.package.testing.SomeClassThree', 'com.some.package.testing.SomeClassFour']
          })",
          "sauce_config({platform: 'android',
                         kind: 'espresso',
                         app: 'path/to/myTestApp.apk',
                         test_app: 'path/to/myTestRunner.apk',
                         path_to_tests: 'path/to/app/src/androidTest',
                         region: 'eu',
                         emulators: [ {name: 'iPhone RDC One', platform_versions: ['11.0']}, {name: 'iPhone RDC Two', platform_versions: ['11.0']}],
                         test_class: ['com.some.package.testing.SomeClassOne', 'com.some.package.testing.SomeClassTwo', 'com.some.package.testing.SomeClassThree', 'com.some.package.testing.SomeClassFour']
          })",
          "sauce_config({platform: 'ios',
                         kind: 'xcuitest',
                         app: 'path/to/myTestApp.app',
                         test_app: 'path/to/myTestRunner.app',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}],
                         test_class: ['MyDemoAppUITests.SomeClassOne', 'MyDemoAppUITests.SomeClassTwo', 'MyDemoAppUITests.SomeClassThree', 'MyDemoAppUITests.SomeClassFour']
          })"
        ]
      end
    end
  end
end
