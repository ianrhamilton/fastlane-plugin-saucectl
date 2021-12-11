require 'find'
require 'open3'
require 'json'
require 'timeout'
require_relative 'file_utils'

module Fastlane
  module Saucectl
    # This class is responsible for creating test execution plans for ios applications and will distribute tests
    # that will be be executed via the cloud provider.
    #
    class AppleTestPlan
      include FileUtils

      TEST_FUNCTION_REGEX = /(test+[A-Z][a-zA-Z]+)[(][)]/.freeze

      def initialize(config)
        @config = config
      end

      def test_plan
        return nil if @config['test_plan'].nil?

        plan_path = Dir["**/#{@config['test_plan']}.xctestplan"][0]
        selected = File.read(plan_path)
        JSON.parse(selected)['testTargets'][0]
      end

      def test_data
        if test_plan.nil? || test_plan.include?('skippedTests')
          strip_skipped(all_tests)
        else
          tests = fetch_selected_tests
          strip_skipped(tests)
        end
      end

      def test_distribution
        test_distribution_check
        tests_arr = []
        case @config['test_distribution']
        when 'class'
          test_data.each { |type| tests_arr << "#{@config['test_target']}.#{type[:class]}" }
        else
          test_data.each do |type|
            type[:tests].each { |test| tests_arr << "#{@config['test_target']}.#{type[:class]}/#{test}" }
          end
        end
        tests_arr.uniq
      end

      def test_distribution_check
        return @config['test_distribution'] if @config['test_distribution'].kind_of?(Array)

        distribution_types = %w[class testCase shard]
        return if distribution_types.include?(@config['test_distribution'])

        raise "#{@config['test_distribution']} is not a valid method of test distribution"
      end

      def strip_skipped(tests)
        if test_plan.nil?
          tests
        else
          enabled_ui_tests = []
          skipped_tests = fetch_disabled_tests
          tests.each do |test|
            enabled_ui_tests << test unless skipped_tests.include?(test)
          end
          enabled_ui_tests
        end
      end

      def fetch_selected_tests
        ui_tests = []
        test_plan['selectedTests'].each do |test|
          test_class = test[%r{[^/]+}]
          ui_tests << { class: test_class, tests: "#{@config['test_target']}.#{test.gsub(/[()]/, '')}" }
        end
        ui_tests
      end

      def fetch_disabled_tests
        skipped = test_plan['skippedTests']
        ui_tests = []
        skipped.each { |test| ui_tests << "#{@config['test_target']}.#{test.gsub(/[()]/, '')}" }
        ui_tests
      end

      def all_tests
        test_details = []
        test_dir = Dir["**/#{@config['test_target']}"][0]
        search_retrieve_test_classes(test_dir).each do |f|
          next unless File.basename(f) =~ FileUtils.CLASS_NAME_REGEX

          test_details << { class: File.basename(f).gsub(FileUtils.FILE_TYPE_REGEX, ''), tests: tests_from(f) }
        end

        strip_empty(test_details)
      end

      def tests_from(path)
        stdout, = find(path, 'func')
        test_cases = []
        stdout.split.each do |line|
          test_cases << line.match(TEST_FUNCTION_REGEX).to_s.gsub(/[()]/, '') if line =~ TEST_FUNCTION_REGEX
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
