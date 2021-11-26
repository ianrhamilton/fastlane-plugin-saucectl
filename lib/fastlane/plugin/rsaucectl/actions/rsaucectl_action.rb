require 'fastlane/action'
require_relative '../helper/rsaucectl_helper'

module Fastlane
  module Actions
    class RsaucectlAction < Action
      def self.run(params)
        UI.message("The rsaucectl plugin is working!")
      end

      def self.description
        "Test your iOS and and Android apps at scale using Sauce Labs toolkit."
      end

      def self.authors
        ["Ian Hamilton"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "With this plugin you can distribute your tests to your VM's in a variety of ways, such as by package (android) by class, or by individual test case."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "RSAUCECTL_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
