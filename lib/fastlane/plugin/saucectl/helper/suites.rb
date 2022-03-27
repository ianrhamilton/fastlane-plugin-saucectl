require 'base64'
require 'fastlane'
require 'fastlane_core/ui/ui'
require_relative 'espresso'
require_relative 'xctest'

module Fastlane
  module Saucectl
    #
    # This class will create test suites based on user specified configuration properties
    #
    class Suites
      include FileUtils

      UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

      def initialize(config)
        @config = config
      end

      def create_test_plan
        check_kind
        if @config[:platform].casecmp('ios').zero?
          is_ios_reqs_satisfied?
          Fastlane::Saucectl::XCTest.new(@config)
        else
          Fastlane::Saucectl::Espresso.new(@config)
        end
      end

      def check_kind
        if @config[:platform].eql?('android')
          UI.user_error!("❌ #{@config[:kind]} is not a supported test framework for android. Use espresso") unless @config[:kind].eql?('espresso')
        else
          UI.user_error!("❌ #{@config[:kind]} is not a supported test framework for iOS. Use xcuitest") unless @config[:kind].eql?('xcuitest')
        end
      end

      def is_ios_reqs_satisfied?
        if @config[:test_target].nil? && @config[:test_plan].nil?
          UI.user_error!("❌ For ios you must specify test_target or test_plan")
        end
      end

      def test_distribution_array
        @config[:test_class] || create_test_plan.test_distribution
      end

      def suite_name(test_type)
        if ENV['JOB_NAME'].nil? && ENV['BUILD_NUMBER'].nil?
          "#{@config[:kind]}-#{test_type.split('.')[-1]}"
        else
          "#{ENV['JOB_NAME']}-#{ENV['BUILD_NUMBER']}-#{test_type.split('.')[-1]}"
        end
      end

      def create_virtual_device_suites
        if @config[:test_distribution] == 'shard'
          shard_virtual_device_suites
        elsif @config[:test_class]
          custom_test_classes
        else
          default_execution_suite
        end
      end

      def shard_virtual_device_suites
        UI.user_error!("❌ Cannot split #{@config[:test_distribution]}'s across virtual devices with a single emulator. \nPlease specify a minimum of two devices!") if @config[:emulators].size.eql?(1)
        test_suites = []
        arr = test_distribution_array
        shards = arr.each_slice((arr.size / @config[:emulators].size.to_f).round).to_a
        shards.each_with_index do |suite, i|
          test_suites << {
            'name' => suite_name("shard #{i + 1}").downcase,
            'testOptions' => default_test_options(suite)
          }.merge(virtual_device_options(@config[:emulators][i]))
        end
        test_suites
      end

      def shard_real_device_suites
        test_suites = []
        arr = test_distribution_array
        shards = arr.each_slice((arr.size / @config[:devices].size.to_f).round).to_a
        shards.each_with_index do |suite, i|
          test_suites << {
            'name' => suite_name("shard #{i + 1}").downcase,
            'testOptions' => default_test_options(suite)
          }.merge(real_device_options(@config[:devices][i]))
        end
        test_suites
      end

      def test_plan_suites
        test_suites = []
        @config[:devices].each do |device|
          test_suites << {
            'name' => suite_name(@config[:test_plan].to_s).downcase,
            'testOptions' => default_test_options(test_distribution_array)
          }.merge(real_device_options(device))
        end
        test_suites
      end

      def custom_test_classes
        test_suites = []
        devices = @config[:devices].nil? ? @config[:emulators] : @config[:devices]
        devices.each do |device|
          device_options = @config[:devices].nil? ? virtual_device_options(device) : real_device_options(device)
          test_classes = @config[:test_class].reject(&:empty?).join(',')
          test_suites << {
            'name' => suite_name(device[:name]).downcase,
            'testOptions' => default_test_options(test_classes.split(','))
          }.merge(device_options)
        end
        test_suites
      end

      def create_real_device_suites
        if !@config[:test_plan].nil? && @config[:test_distribution].eql?('class')
          test_plan_suites
        elsif @config[:test_distribution] == 'shard'
          shard_real_device_suites
        elsif @config[:test_class].kind_of?(Array)
          custom_test_classes
        else
          default_execution_suite
        end
      end

      def default_execution_suite
        type = @config[:annotation] ? 'annotation' : 'size'
        UI.user_error!("❌ execution by #{type} is not supported on the iOS platform!") if @config[:platform].eql?('ios') && (@config[:size] || @config[:annotation])
        is_real_device = @config[:devices]
        test_devices = @config[:devices] || @config[:emulators]
        test_suites = []
        if @config[:size] || @config[:annotation]
          test_devices.each do |device|
            test_suites << {
              'name' => suite_name(@config[:size] || @config[:annotation]).downcase,
              'testOptions' => default_test_options(@config[:size])
            }.merge(is_real_device ? real_device_options(device) : virtual_device_options(device))
          end
        else
          test_devices.each do |device|
            test_distribution_array.each do |test_type|
              test_suites << {
                'name' => suite_name(test_type).downcase,
                'testOptions' => default_test_options(test_type)
              }.merge(is_real_device ? real_device_options(device) : virtual_device_options(device))
            end
          end
        end
        test_suites
      end

      def virtual_device_options(device)
        platform_versions = device[:platform_versions].reject(&:empty?).join(',')
        { 'emulators' => [{ 'name' => device[:name],
                            'orientation' => device[:orientation],
                            'platformVersions' => platform_versions.split(',') }] }
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
        if @config[:platform] == 'android'
          test_option_type(test_type)
        else
          { 'class' => test_type }
        end
      end

      def test_option_type(test_type)
        if @config[:size] || @config[:annotation]
          key = @config[:size] ? 'size' : 'annotation'
          value = @config[:size] || @config[:annotation]
          { key => value }.merge(android_test_options)
        else
          test_option_type = @config[:test_distribution].eql?('package') ? 'package' : 'class'
          { test_option_type => test_type }.merge(android_test_options)
        end
      end

      def android_test_options
        {
          'clearPackageData' => @config[:clear_data],
          'useTestOrchestrator' => @config[:use_test_orchestrator]
        }
      end
    end
  end
end
