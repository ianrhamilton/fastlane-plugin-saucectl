require_relative '../helper/runner'

module Fastlane
  module Actions
    class SauceRunnerAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")

      def self.run(run = '')
        Saucectl::Runner.new.execute
      end

      def self.description
        "Execute automated tests on sauce labs platform via saucectl binary for specified configuration"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :sauce_username,
                                       env_name: "SAUCE_USERNAME",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_USERNAME],
                                       description: "Your sauce labs username",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['sauce_username_error']) if value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :sauce_access_key,
                                       env_name: "SAUCE_ACCESS_KEY",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_ACCESS_KEY],
                                       description: "Your sauce labs access key",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['sauce_api_key_error']) if value.empty?
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
    end
  end
end
