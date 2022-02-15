require 'fastlane_core/ui/ui'
require 'fastlane'
require 'open-uri'

module Fastlane
  module Saucectl
    #
    # This class provides the functions required to install the saucectl binary
    #
    class Installer
      def install
        timeout_in_seconds = 30
        Timeout.timeout(timeout_in_seconds) do
          download_saucectl_installer
          execute_saucectl_binary
          UI.success("✅ Successfully installed saucectl runner binary 🚀")
        rescue StandardError => e
          UI.user_error!("❌ Failed to install saucectl binary: #{e}")
        end
      end

      def download_saucectl_installer
        open('sauce', 'wb') do |file|
          open('https://saucelabs.github.io/saucectl/install').read
          file << open('https://saucelabs.github.io/saucectl/install').read
        end
      end

      def execute_saucectl_binary
        system('sh sauce')
        FileUtils.mv('bin', '.sauce') unless Dir.exist?('.sauce')
      end
    end
  end
end
