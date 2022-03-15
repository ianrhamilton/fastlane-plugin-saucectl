require 'fastlane/action'
require_relative '../helper/api'

module Fastlane
  module Actions
    class SauceDevicesAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")

      def self.run(params)
        platform = params[:platform]
        case platform
        when 'android'
          Fastlane::Saucectl::Api.new(params).fetch_android_devices
        when 'ios'
          Fastlane::Saucectl::Api.new(params).fetch_ios_devices
        else
          Fastlane::Saucectl::Api.new(params).available_devices
        end
      end

      def self.description
        "Returns a list of Device IDs for all devices in the data center that are currently free for testing."
      end

      def self.details
        "Returns a list of Device IDs for all devices in the data center that are currently free for testing."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :platform,
                                       description: "Device platform that you wish to query",
                                       optional: true,
                                       is_string: true,
                                       default_value: ''),
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
          "sauce_devices({platform: 'android',
                          region: 'eu',
                          sauce_username: 'foo',
                          sauce_access_key: 'bar123',
                       })",
          "sauce_devices({region: 'eu',
                          sauce_username: 'foo',
                          sauce_access_key: 'bar123',
                       })",
          "sauce_devices({region: 'us',
                          sauce_username: 'foo',
                          sauce_access_key: 'bar123',
                       })"
        ]
      end
    end
  end
end
