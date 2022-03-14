require 'fastlane/action'
require 'json'
require 'yaml'
require_relative '../helper/api'

module Fastlane
  module Actions
    class SauceAppsAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")
      def self.run(params)
        Fastlane::Saucectl::Api.new(params).retrieve_all_apps
      end

      def self.description
        "Returns the set of files by specific app id that have been uploaded to Sauce Storage by the requester"
      end

      def self.details
        "Returns the set of files by specific app id that have been uploaded to Sauce Storage by the requester"
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
          FastlaneCore::ConfigItem.new(key: :query,
                                       description: "Any search term (such as build number or file name) by which you want to filter results",
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['missing_file_name']) if value.to_s.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :region,
                                       description: "Data Center region (us or eu), set using: region: 'eu'",
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['region_error'].gsub!('$region', value)) unless @messages['supported_regions'].include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :sauce_username,
                                       env_name: "SAUCE_USERNAME",
                                       description: "Your sauce labs username in order to authenticate upload requests",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_USERNAME],
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['sauce_username_error']) unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :sauce_access_key,
                                       env_name: "SAUCE_ACCESS_KEY",
                                       description: "Your sauce labs access key in order to authenticate upload requests",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_ACCESS_KEY],
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['sauce_api_key_error']) unless value && !value.empty?
                                       end)
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
          "sauce_apps({platform: 'android',
                       query: 'test.apk',
                       region: 'eu',
                       sauce_username: 'foo',
                       sauce_access_key: 'bar123',
                     })",
          "sauce_apps({platform: 'ios',
                       query: 'test.app',
                       region: 'eu',
                       sauce_username: 'foo',
                       sauce_access_key: 'bar123',
                     })"
        ]
      end

      def self.return_value
        "Returns the set of files that have been uploaded to Sauce Storage by the requestor."
      end
    end
  end
end
