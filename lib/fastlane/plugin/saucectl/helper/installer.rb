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

      def install(version)
        timeout_in_seconds = 90
        Timeout.timeout(timeout_in_seconds) do
          download_saucectl_installer
          execute_saucectl_installer(version)
          UI.success("✅ Successfully installed saucectl runner binary 🚀")
        rescue OpenURI::HTTPError => e
          response = e.io
          UI.user_error!("❌ Failed to install saucectl binary: status #{response.status[0]}")
        end
      end

      def download_saucectl_installer
        URI.open('sauce', 'wb') do |file|
          file << URI.open('https://saucelabs.github.io/saucectl/install', ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
        end
      end

      def execute_saucectl_installer(version)
        saucectl_version = version[:version].nil? ? '' : "v#{version[:version]}"
        status = system("sh sauce #{saucectl_version}")
        status == 1 ? UI.user_error!("❌ failed to install saucectl") : status
        executable = 'saucectl'
        FileUtils.mv("bin/#{executable}", executable) unless File.exist?(executable)
      end

      def system(*cmd)
        Open3.popen2e(*cmd) do |stdin, stdout_stderr, wait_thread|
          Thread.new do
            stdout_stderr.each do |out|
              UI.message(out)
            end
          end
          stdin.close
          wait_thread.value
        end
      end
    end
  end
end
