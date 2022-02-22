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

      def install
        download_saucectl_installer
        execute_saucectl_binary
      end

      def download_saucectl_installer
        UI.message('Installing Sauce toolkit installer')
        URI.open('sauce', 'wb') do |file|
          file << URI.open('https://saucelabs.github.io/saucectl/install').read
        end
      end

      def execute_saucectl_binary
        _stdout, stderr, status = syscall("sh sauce")
        response = stderr.io
        status.exitstatus == 1 ? UI.user_error!("❌ Failed to install saucectl binary: status code #{response.status}") : status
        FileUtils.mv('bin', '.sauce') unless Dir.exist?('.sauce')
        UI.success("✅ Successfully installed saucectl runner binary 🚀")
      end
    end
  end
end
