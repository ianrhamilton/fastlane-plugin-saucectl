require 'fastlane_core/ui/ui'
require 'fastlane'

module Fastlane
  module Saucectl
    #
    # This class provides the functions required to install the saucectl binary
    #
    class Installer
      UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

      def self.install
        timeout_in_seconds = 30
        Timeout.timeout(timeout_in_seconds) do
          download_saucectl_installer
          execute_saucectl_binary
          UI.success("✅ Successfully installed saucectl runner binary 🚀")
        rescue StandardError => e
          UI.user_error!("❌ Failed to install saucectl binary: #{e}")
        end
      end

      def self.download_saucectl_installer
        open('sauce', 'wb') do |file|
          file << open('https://saucelabs.github.io/saucectl/install').read
        end
      end

      def self.execute_saucectl_binary
        system('sh sauce')
        FileUtils.mv('bin', '.sauce') unless Dir.exist?('.sauce')
      end
    end
  end
end
