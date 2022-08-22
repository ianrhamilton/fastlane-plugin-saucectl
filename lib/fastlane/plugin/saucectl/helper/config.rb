require 'fileutils'
require 'yaml'
require 'uri'
require 'net/http'
require 'json'
require 'base64'
require 'open3'
require_relative 'ios_suites'
require_relative 'android_suites'

module Fastlane
  module Saucectl
    #
    # This class creates saucectl config.yml file based on given specifications
    #
    class ConfigGenerator
      UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

      def initialize(config)
        @config = config
      end

      def base_config
        {
          'apiVersion' => 'v1alpha',
          'kind' => @config[:kind],
          'defaults' => {
            'timeout' => @config[:timeout],
          },
          'sauce' => {
            'region' => set_region.to_s,
            'concurrency' => @config[:max_concurrency_size],
            'retries' => @config[:retries]
          },
          (@config[:kind]).to_s => set_apps,
          'artifacts' => {
            'download' => {
              'when' => 'always',
              'match' => ['junit.xml'],
              'directory' => './artifacts/'
            }
          },
          'reporters' => {
            'junit' => {
              'enabled' => true
            }
          }
        }
      end

      def set_region
        @config[:region] == 'eu' ? 'eu-central-1' : 'us-west-1'
      end

      def set_apps
        {
          'app' => @config[:app],
          'testApp' => @config[:test_app]
        }
      end

      def suite
        @config[:platform].eql?('ios') ? Fastlane::Saucectl::IosSuites.new(@config) : Fastlane::Saucectl::AndroidSuites.new(@config)
      end

      def create
        UI.message("Creating saucectl config .....🚕💨")
        file_name = 'config.yml'
        UI.user_error!("❌ Sauce Labs platform does not support virtual device execution for ios apps") if @config[:platform].eql?('ios') && @config[:emulators]

        config = base_config.merge({ 'suites' => suite.generate })
        out_file = File.new(file_name, 'w')
        out_file.puts(config.to_yaml)
        out_file.close
        creat_sauce_dir
        FileUtils.move(file_name, './.sauce')
        UI.message("Successfully created saucectl config ✅") if Dir.exist?('.sauce')
        UI.user_error!("Failed to create saucectl config ❌") unless Dir.exist?('.sauce')
      end

      def creat_sauce_dir
        dirname = '.sauce'
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      end
    end
  end
end
