require 'fastlane/action'
require_relative '../helper/installer'

module Fastlane
  module Actions
    class InstallAction < Action
      def self.run
        UI.message("Installing saucectl 🤖 🚀")
        installer = Saucectl::Installer.new
        installer.install
      end

      def self.description
        "Install sauce labs toolkit binary"
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
