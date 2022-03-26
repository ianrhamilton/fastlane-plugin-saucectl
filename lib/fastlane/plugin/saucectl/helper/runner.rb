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
      UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

      def execute
        unless File.exist?(EXECUTABLE)
          UI.user_error!("❌ sauce labs executable file does not exist! Expected sauce executable file to be located at:'#{Dir.pwd}/#{EXECUTABLE}'")
        end

        system("chmod +x #{EXECUTABLE}")
        system("./#{EXECUTABLE} run")
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
