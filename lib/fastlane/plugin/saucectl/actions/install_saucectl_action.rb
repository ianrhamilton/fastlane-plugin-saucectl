require 'fastlane/action'
require_relative '../helper/installer'

module Fastlane
  module Actions
    class InstallSaucectlAction < Action
      def self.run(version = nil)
        version_message = version[:version].nil? ? 'Installing with latest version of saucectl' : "Installing saucectl with version #{version[:version]}"
        UI.message("#{version_message} 🤖 🚀")
        installer = Saucectl::Installer.new
        installer.install(version)
      end

      def self.description
        "Installs the Sauce Labs saucectl cli binary"
      end

      def self.details
        "Optionally set the tag of the version you wish to install. If not tag is set, the latest tag will be downloaded. See: https://github.com/saucelabs/saucectl/tags "
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       description: "Set the tag of saucectl you wish to install",
                                       optional: true,
                                       type: Integer)
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
