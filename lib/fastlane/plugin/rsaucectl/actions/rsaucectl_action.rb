require 'fastlane/action'
require_relative '../helper/installer'

module Fastlane
  module Actions
    class RsaucectlInstallAction < Action
      def self.run(config)
        UI.message("Installing saucectl 🤖 🚀")

        installer = Saucectl::Installer.new
        installer.install

        if file.to_s.length == 0
          UI.user_error!("Couldn't find build file at path #{file}` ❌")
        end
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
        [:ios, :android].include?(platform)
      end
    end
  end
end
