require 'fastlane_core/ui/ui'
require 'fastlane'
require 'open-uri'
require_relative 'file_utils'

module Fastlane
  module Saucectl
    #
    # This class provides the functions required to install the saucectl binary
    #
    class Installer
      include FileUtils
      UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

      def install
        timeout_in_seconds = 30
        Timeout.timeout(timeout_in_seconds) do
          download_saucectl_installer
          execute_saucectl_binary
          UI.success("✅ Successfully installed saucectl runner binary 🚀")
        rescue OpenURI::HTTPError => e
          response = e.io
          UI.user_error!("❌ Failed to install saucectl binary: status #{response.status[0]}")
        end
      end

      def download_saucectl_installer
        open('sauce', 'wb') do |file|
          file << open('https://saucelabs.github.io/saucectl/install').read
        end
      end

      def execute_saucectl_binary
        _stdout, stderr, status = syscall('sh sauce')
        status.exitstatus == 1 ? UI.user_error!("❌ failed to install saucectl: #{stderr}") : status
        FileUtils.mv('bin', '.sauce') unless Dir.exist?('.sauce')
      end
    end
  end
end
