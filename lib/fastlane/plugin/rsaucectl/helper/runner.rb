require 'fastlane'
require 'open3'
require 'fastlane_core/ui/ui'
require_relative "file_utils"

module Fastlane
  module Saucectl
    #
    # This class provides the ability to execute tests via configured specifications and capture the output of the sauce executable.
    #
    class Runner
      include FileUtils
      EXECUTABLE = 'saucectl'

      def execute(config)
        unless File.exist?(EXECUTABLE)
          UI.user_error!("❌ sauce labs executable file does not exist! Expected sauce executable file to be located at:'#{Dir.pwd}/#{EXECUTABLE}'")
        end

        stdout, stderr, status = syscall("./#{EXECUTABLE} run")
        status.exitstatus == 1 ? UI.user_error!("❌ #{stderr}") : status
      end
    end
  end
end
