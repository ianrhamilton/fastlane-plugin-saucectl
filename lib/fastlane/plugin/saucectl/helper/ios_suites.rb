require 'base64'
require 'fastlane'
require 'fastlane_core/ui/ui'
require_relative 'espresso'
require_relative 'xctest'

module Fastlane
  module Saucectl
    #
    # This class will create test suites for ios applications based on user specified configuration properties
    #
    class IosSuites
      include FileUtils

      UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

      def initialize(config)
        UI.user_error!("❌ For the ios platform you must specify `devices` array") if config[:devices].nil?
        UI.user_error!("❌ #{config[:kind]} is not a supported test framework for iOS. Use xcuitest") unless config[:kind].eql?('xcuitest')
        @config = config
      end

      def generate
        check_for_android_params

        if @config[:test_distribution] || @config[:test_plan]
          create_test_distribution_suite
        elsif @config[:test_class].kind_of?(Array)
          custom_test_class_suite
        else
          test_runner_suite
        end
      end

      def check_for_android_params
        type = @config[:annotation] ? 'annotation' : 'size'
        UI.user_error!("❌ execution by #{type} is not supported on the iOS platform!") if @config[:size] || @config[:annotation]
      end

      def create_test_distribution_suite
        if @config[:test_distribution].eql?('shard')
          shard_real_device_suites
        else
          test_distribution_suite
        end
      end

      def test_distribution_array
        @config[:test_class] || Fastlane::Saucectl::XCTest.new(@config).test_distribution
      end

      def suite_name(name)
        if ENV['JOB_NAME'].nil? && ENV['BUILD_NUMBER'].nil?
          "#{@config[:kind]}-#{name}"
        else
          "#{ENV['JOB_NAME']}-#{ENV['BUILD_NUMBER']}-#{name}"
        end
      end

      def shard_real_device_suites
        test_suites = []
        arr = test_distribution_array
        shards = arr.each_slice((arr.size / @config[:devices].size.to_f).round).to_a
        shards.each_with_index do |suite, i|
          device_name = @config[:devices][i].key?(:id) ? @config[:devices][i][:id] : @config[:devices][i][:name]
          test_suites << {
            'name' => suite_name("#{device_name}-shard-#{i + 1}").downcase,
            'testOptions' => default_test_options(suite)
          }.merge(real_device_options(@config[:devices][i]))
        end
        test_suites
      end

      def test_runner_suite
        test_suites = []
        @config[:devices].each do |device|
          device_name = device.key?(:id) ? device[:id] : device[:name]
          test_suites << {
            'name' => suite_name(device_name),
            'testOptions' => default_test_options(nil)
          }.merge(real_device_options(device))
        end
        test_suites
      end

      def custom_test_class_suite
        test_suites = []
        @config[:devices].each do |device|
          device_options = real_device_options(device)
          test_classes = @config[:test_class].reject(&:empty?).join(',')
          test_suites << {
            'name' => suite_name(device[:name]).downcase,
            'testOptions' => default_test_options(test_classes.split(','))
          }.merge(device_options)
        end
        test_suites
      end

      def test_distribution_suite
        test_suites = []
        if @config[:test_plan]
          @config[:devices].each do |device|
            test_suites << {
              'name' => suite_name(@config[:test_plan]).downcase,
              'testOptions' => default_test_options(test_distribution_array)
            }.merge(real_device_options(device))
          end
        else
          @config[:devices].each do |device|
            test_distribution_array.each do |test_type|
              test_suites << {
                'name' => suite_name(test_type).downcase,
                'testOptions' => default_test_options(test_type)
              }.merge(real_device_options(device))
            end
          end
        end
        test_suites
      end

      def test_plan_distribution
        test_suites = []
        @config[:devices].each do |device|
          test_suites << {
            'name' => suite_name(@config[:test_plan]).downcase,
            'testOptions' => default_test_options(test_distribution_array)
          }.merge(real_device_options(device))
        end
        test_suites
      end

      def real_device_options(device)
        { 'devices' => [rdc_options(device)] }
      end

      def rdc_options(device)
        device_type_key = device.key?(:id) ? 'id' : 'name'
        name = device.key?(:id) ? device[:id] : device[:name]
        base_device_hash = {
          device_type_key => name,
          'orientation' => device[:orientation]
        }.merge('options' => device_options(device))

        unless device[:platform_version].nil?
          base_device_hash = base_device_hash.merge({ 'platformVersion' => device[:platform_version] })
        end

        base_device_hash
      end

      def device_options(device)
        {
          'carrierConnectivity' => device[:carrier_connectivity],
          'deviceType' => device[:device_type].upcase!,
          'private' => device[:private]
        }
      end

      def default_test_options(test_type)
        unless test_type.nil?
          { 'class' => test_type }
        end
      end
    end
  end
end
