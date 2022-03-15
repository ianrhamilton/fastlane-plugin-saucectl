require 'fastlane/action'
require 'json'
require 'yaml'
require_relative '../helper/espresso'
require_relative '../helper/xctest'

module Fastlane
  module Actions
    class DisabledTestsAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")

      def self.run(params)
        verify_config(params)
        if params[:platform].eql?('android')
          params[:path_to_tests] ? params[:path_to_tests] : params[:path_to_tests] = "app/src/androidTest"
          Fastlane::Saucectl::Espresso.new(params).fetch_disabled_tests(params[:path_to_tests])
        else
          Fastlane::Saucectl::XCTest.new(params).fetch_disabled_tests
        end
      end

      def self.verify_config(params)
        if params[:platform].eql?('ios') && params[:test_plan].nil?
          UI.user_error!('Cannot get skipped tests for an ios project without a known test_plan')
        end
        if params[:platform].eql?('android') && !params[:test_plan].nil?
          UI.user_error!('test_plan option is reserved for ios projects only')
        end
      end

      def self.description
        "Returns set of disabled ui test cases"
      end

      def self.details
        "Returns set of disabled ui test cases, for android searches for @Ignore tests, and for ios skipped tests within an xcode test plan"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :platform,
                                       description: "application under test platform (ios or android)",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['platform_error']) if value.to_s.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :path_to_tests,
                                       description: "Android only, path to espresso tests. Default to app/src/androidTest",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :test_plan,
                                       description: "Name of xcode test plan",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :test_target,
                                       description: "Name of xcode test target",
                                       optional: true,
                                       is_string: true)
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
          "disabled_tests({ platform: 'android',
                            path_to_tests: 'my-demo-app-android/app/src/androidTest'
          })",
          "disabled_tests({ platform: 'ios',
                            test_plan: 'UITests'
          })",
          "disabled_tests({ platform: 'ios',
                            test_plan: 'UITests'
          })"
        ]
      end
    end
  end
end
