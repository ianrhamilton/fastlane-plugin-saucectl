require 'fileutils'
require 'yaml'
require 'uri'
require 'net/http'
require 'json'
require 'base64'
require 'open3'
require_relative 'suites'

module Fastlane
  module Saucectl
    #
    # This class creates saucectl config.yml file based on given specifications
    #
    class SaucectlConfigGenerator
      def initialize(config)
        @config = config
      end

      def base_config
        {
          'apiVersion' => 'v1alpha',
          'kind' => @config['kind'],
          'sauce' => {
            'region' => @config['region'],
            'concurrency' => @config['max_concurrency_size'],
            'metadata' => {
              'name' => "#{ENV['JOB_NAME']}-#{ENV['BUILD_NUMBER']}",
              'build' => "Release #{ENV['CI_COMMIT_SHORT_SHA']}"
            }
          },
          (@config['kind']).to_s => {
            'app' => "#{@config['app_path']}/#{@config['app_name']}",
            'testApp' => "#{@config['app_path']}/#{@config['test_runner_app']}"
          },
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

      def create
        file_name = 'config.yml'
        suite = Fastlane::Saucectl::Suites.new(@config)
        suites = { 'suites' => if @config[:is_virtual_device]
                                 suite.create_virtual_device_suites
                               else
                                 suite.create_real_device_suites
                               end }
        config = base_config.merge(suites)
        out_file = File.new(file_name, 'w')
        out_file.puts(config.to_yaml)
        out_file.close
        creat_sauce_dir
        FileUtils.move(file_name, './.sauce')
      end

      def creat_sauce_dir
        dirname = '.sauce'
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      end
    end
  end
end
