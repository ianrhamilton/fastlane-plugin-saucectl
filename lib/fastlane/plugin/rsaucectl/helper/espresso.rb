require "find"
require "open3"
require "json"
require_relative "file_utils"

module Fastlane
  module Saucectl
    # This class is responsible for creating test execution plans for ios applications and will distribute tests
    # that will be be executed via the cloud provider.
    #
    class Espresso
      include FileUtils

      TEST_FUNCTION_REGEX = /([a-z]+[A-Z][a-zA-Z]+)[(][)]/.freeze
      DEFAULT_PATH_TO_TESTS = "app/src/androidTest"

      def initialize(config)
        @config = config
        @path_to_tests = config["path_to_tests"].nil? ? DEFAULT_PATH_TO_TESTS : config["path_to_tests"]
      end

      def test_data
        test_details = []
        search_retrieve_test_classes(@path_to_tests).each do |f|
          next unless File.basename(f) =~ CLASS_NAME_REGEX

          test_details << { package: File.readlines(f).first.chomp.gsub("package ", "").gsub(";", ""),
                            class: File.basename(f).gsub(FILE_TYPE_REGEX, ""),
                            tests: tests_from(f) }
        end

        strip_empty(test_details)
      end

      def test_distribution
        test_distribution_check
        tests_arr = []
        case @config["test_distribution"]
        when "package"
          test_data.each { |type| tests_arr << type[:package] }
        when "class"
          test_data.each { |type| tests_arr << "#{type[:package]}.#{type[:class]}" }
        else
          test_data.each do |type|
            type[:tests].each { |test| tests_arr << "#{type[:package]}.#{type[:class]}##{test}" }
          end
        end
        tests_arr.uniq
      end

      def test_distribution_check
        return @config["test_distribution"] if @config["test_distribution"].is_a?(Array)

        distribution_types = %w[class testCase package shard]
        return if distribution_types.include?(@config["test_distribution"]) || @config["test_distribution"].nil?

        raise "#{@config["test_distribution"]} is not a valid method of test distribution"
      end

      def strip_empty(test_details)
        tests = []
        test_details.each { |test| tests << test unless test[:tests].size.zero? }
        tests
      end

      def tests_from(path)
        stdout, = find(path, "@Test")
        test_cases = []
        stdout.split.each do |line|
          test_cases << line.match(TEST_FUNCTION_REGEX).to_s.gsub(/[()]/, "") if line =~ TEST_FUNCTION_REGEX
        end
        strip_skipped(path, test_cases)
      end

      def fetch_disabled_tests(path)
        stdout, = find(path, "@Ignore")
        test_cases = []
        stdout.split.each do |line|
          test_cases << line.match(TEST_FUNCTION_REGEX).to_s.gsub(/[()]/, "") if line =~ TEST_FUNCTION_REGEX
        end
        test_cases
      end

      def strip_skipped(path, tests)
        enabled_ui_tests = []
        skipped_tests = fetch_disabled_tests(path)
        tests.each do |test|
          enabled_ui_tests << test unless skipped_tests.include?(test)
        end
        enabled_ui_tests
      end
    end
  end
end
