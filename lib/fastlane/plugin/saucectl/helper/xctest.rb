require "find"
require "open3"
require "json"
require_relative "file_utils"

module Fastlane
  module Saucectl
    # This class is responsible for creating test execution plans for ios applications and will distribute tests
    # that will be be executed via the cloud provider.
    #
    class XCTest
      include FileUtils
      UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)
      TEST_FUNCTION_REGEX = /(test+[A-Z][a-zA-Z]+)[(][)]/.freeze

      def initialize(config)
        @config = config
      end

      def test_plan_exists?
        File.exist?(Dir["**/#{@config[:test_plan]}.xctestplan"][0])
      rescue StandardError
        false
      end

      def valid_test_plan?
        File.exist?(Dir["**/#{@config[:test_plan]}.xctestplan"][0])
      rescue StandardError
        UI.user_error!("#{@config[:test_plan]} was not found in workspace")
      end

      def fetch_test_plan
        plan_path = Dir["**/#{@config[:test_plan]}.xctestplan"][0]
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
        @config[:test_target].nil? ? fetch_target_from_test_plan : @config[:test_target]
      end

      def test_distribution
        test_distribution_check
        tests_arr = []

        test_distribution = @config[:test_plan].nil? ? @config[:test_distribution] : 'testPlan'
        case test_distribution
        when 'testCase', 'shard', 'testPlan'
          test_data.each do |type|
            type[:tests].each { |test| tests_arr << "#{test_target}.#{type[:class]}/#{test}" }
          end
        else
          test_data.each do |type|
            tests_arr << "#{test_target}.#{type[:class]}"
          end
        end
        tests_arr.uniq
      end

      def test_distribution_check
        return @config[:test_distribution] if @config[:test_distribution].kind_of?(Array)

        distribution_types = %w[class testCase shard]
        unless distribution_types.include?(@config[:test_distribution]) || @config[:test_distribution].nil?
          UI.user_error!("#{@config[:test_distribution]} is not a valid method of test distribution. \n Supported types for iOS: \n #{distribution_types}")
        end
      end

      def fetch_selected_tests
        ui_tests = []
        fetch_test_plan["selectedTests"].each do |test|
          test_case = test.gsub('/', ' ').split
          ui_tests << { class: test_case[0], tests: [test_case[1].gsub(/[()]/, "").to_s] }
        end
        ui_tests
      end

      def strip_skipped(all_tests)
        enabled_ui_tests = []
        skipped_tests = fetch_disabled_tests
        all_tests.each do |tests|
          tests[:tests].each do |test|
            unless skipped_tests.to_s.include?(test)
              enabled_ui_tests << { class: tests[:class].to_s, tests: [test] }
            end
          end
        end
        enabled_ui_tests
      end

      def fetch_disabled_tests
        skipped = fetch_test_plan["skippedTests"]
        ui_tests = []
        skipped.each do |item|
          if item.include?('/')
            test_case = item.gsub('/', ' ').split
            ui_tests << sort_ui_tests(test_case[0], test_case[1])
          else
            ui_tests << scan_test_class(item)
          end
        end
        ui_tests
      end

      def sort_ui_tests(cls, test_case)
        { class: cls, tests: test_case.gsub(/[()]/, "").to_s }
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

      def scan_test_class(cls)
        test_details = []
        test_dir = Dir["**/#{test_target}"][0]
        search_retrieve_test_classes(test_dir).each do |f|
          next unless File.basename(f) =~ /#{cls}/

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
