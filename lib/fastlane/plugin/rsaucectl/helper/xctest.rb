require "find"
require "open3"
require "json"
require_relative "file_utils"
include FileUtils

module Fastlane
  module Saucectl
    # This class is responsible for creating test execution plans for ios applications and will distribute tests
    # that will be be executed via the cloud provider.
    #
    class XCTest

      TEST_FUNCTION_REGEX = /(test+[A-Z][a-zA-Z]+)[(][)]/.freeze

      def initialize(config)
        @config = config
      end

      def test_plan_exists?
        File.exist?(Dir["**/#{@config['test_plan']}.xctestplan"][0])
      rescue StandardError
        false
      end

      def valid_test_plan?
        File.exist?(Dir["**/#{@config['test_plan']}.xctestplan"][0])
      rescue StandardError
        raise "#{@config['test_plan']} was not found in workspace"
      end

      def fetch_test_plan
        plan_path = Dir["**/#{@config['test_plan']}.xctestplan"][0]
        selected = File.read(plan_path)
        JSON.parse(selected)["testTargets"][0]
      end

      def fetch_target_from_test_plan
        fetch_test_plan["target"]["name"]
      end

      def test_data
        if test_plan_exists?
          valid_test_plan?
          if fetch_test_plan.include?("skippedTests")
            strip_skipped(all_tests)
          else
            fetch_selected_tests
          end
        else
          all_tests
        end
      end

      def test_target
        @config["test_target"].nil? ? fetch_target_from_test_plan : @config["test_target"]
      end

      def test_distribution
        test_distribution_check
        tests_arr = []
        case @config["test_distribution"]
        when "class"
          test_data.each { |type| tests_arr << "#{test_target}.#{type[:class]}" }
        else
          test_data.each do |type|
            type[:tests].each { |test| tests_arr << "#{test_target}.#{type[:class]}/#{test}" }
          end
        end
        tests_arr.uniq
      end

      def test_distribution_check
        return @config["test_distribution"] if @config["test_distribution"].is_a?(Array)

        distribution_types = %w[class testCase shard]
        unless distribution_types.include?(@config["test_distribution"]) || @config["test_distribution"].nil?
          raise "#{@config['test_distribution']} is not a valid method of test distribution"
        end
      end

      def strip_skipped(all_tests)
        enabled_ui_tests = []
        skipped_tests = fetch_disabled_tests
        all_tests.each do |tests|
          tests[:tests].each do |test|
            unless skipped_tests.include?(test)
              enabled_ui_tests << "#{test_target}.#{tests[:class]}/#{test.partition('.')[2]}"
            end
          end
        end
        enabled_ui_tests
      end

      def fetch_selected_tests
        ui_tests = []
        fetch_test_plan["selectedTests"].each do |test|
          test_class = test[%r{[^/]+}]
          ui_tests << { class: test_class.to_s, tests: "#{test_target}.#{test.gsub(/[()]/, '')}" }
        end
        ui_tests
      end

      def fetch_disabled_tests
        skipped = fetch_test_plan["skippedTests"]
        ui_tests = []
        skipped.each { |test| ui_tests << test.gsub(/[()]/, "").to_s }
        ui_tests
      end

      def all_tests
        test_details = []
        test_dir = Dir["**/#{test_target}"][0]
        search_retrieve_test_classes(test_dir).each do |f|
          next unless File.basename(f) =~ CLASS_NAME_REGEX

          test_details << { class: File.basename(f).gsub(FILE_TYPE_REGEX, ""), tests: tests_from(f) }
        end

        strip_empty(test_details)
      end

      def tests_from(path)
        stdout, = find(path, "func")
        test_cases = []
        stdout.split.each do |line|
          test_cases << line.match(TEST_FUNCTION_REGEX).to_s.gsub(/[()]/, "") if line =~ TEST_FUNCTION_REGEX
        end
        test_cases
      end

      def strip_empty(test_details)
        tests = []
        test_details.each do |test|
          tests << test unless test[:tests].size.zero?
        end
        tests
      end
    end
  end
end
