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
    class AndroidSuites
      include FileUtils

      UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

      def initialize(config)
        UI.user_error!("❌ #{config[:kind]} is not a supported test framework for android. Use espresso") unless config[:kind].eql?('espresso')
        @devices = config[:devices].nil? ? config[:emulators] : config[:devices]
        @is_real_device = config[:emulators].nil?
        @config = config
      end

      def generate
        if @config[:test_distribution] || @config[:size] || @config[:annotation]
          create_test_distribution_suite
        elsif @config[:test_class].kind_of?(Array)
          custom_test_class_suite
        else
          test_runner_suite
        end
      end

      def test_distribution_array
        @config[:test_class] || Fastlane::Saucectl::Espresso.new(@config).test_distribution
      end

      def suite_name(test_type)
        if ENV['JOB_NAME'].nil? && ENV['BUILD_NUMBER'].nil?
          "#{@config[:kind]}-#{test_type}"
        else
          "#{ENV['JOB_NAME']}-#{ENV['BUILD_NUMBER']}-#{test_type}"
        end
      end

      def shard_suites
        UI.user_error!("❌ Cannot split #{@config[:test_distribution]}'s across devices with a single device/emulator. \nPlease specify a minimum of two devices/emulators!") if @devices.size.eql?(1)

        test_suites = []
        arr = test_distribution_array
        shards = arr.each_slice((arr.size / @devices.size.to_f).round).to_a
        shards.each_with_index do |suite, i|
          device_options = @is_real_device ? real_device_options(@devices[i]) : virtual_device_options(@devices[i])
          test_suites << {
            'name' => suite_name("shard #{i + 1}").downcase,
            'testOptions' => test_option_type(suite)
          }.merge(device_options)
        end
        test_suites
      end

      def test_runner_suite
        test_suites = []
        @devices.each do |device|
          device_options = @is_real_device ? real_device_options(device) : virtual_device_options(device)
          device_name = device.key?(:id) ? device[:id] : device[:name]
          test_suites << {
            'name' => suite_name(device_name),
            'testOptions' => test_option_type
          }.merge(device_options)
        end
        test_suites
      end

      def custom_test_class_suite
        test_suites = []
        @devices.each do |device|
          device_options = @is_real_device ? real_device_options(device) : virtual_device_options(device)
          test_classes = @config[:test_class].reject(&:empty?).join(',')
          test_suites << {
            'name' => suite_name(device[:name]).downcase,
            'testOptions' => test_option_type(test_classes.split(','))
          }.merge(device_options)
        end
        test_suites
      end

      def create_test_distribution_suite
        if @config[:test_distribution].eql?('shard')
          shard_suites
        else
          test_distribution_suite
        end
      end

      def test_distribution_suite
        UI.user_error!("❌ to distribute tests you must specify the path to your espresso tests. For example `path_to_tests:someModule/src/androidTest`") if @config[:path_to_tests].nil?

        test_suites = []
        if @config[:size] || @config[:annotation]
          @devices.each do |device|
            device_options = @is_real_device ? real_device_options(device) : virtual_device_options(device)
            test_suites << {
              'name' => suite_name(device[:name]).downcase,
              'testOptions' => test_option_type
            }.merge(device_options)
          end
        else
          @devices.each do |device|
            device_options = @is_real_device ? real_device_options(device) : virtual_device_options(device)
            test_distribution_array.each do |test_type|
              test_suites << {
                'name' => suite_name(test_type).downcase,
                'testOptions' => test_option_type(test_type)
              }.merge(device_options)
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

      def test_option_type(test_type = nil)
        if @config[:size] || @config[:annotation]
          key = @config[:size] ? 'size' : 'annotation'
          value = @config[:size] || @config[:annotation]
          { key => value }.merge(android_test_options)
        else
          if test_type.nil?
            android_test_options
          else
            test_option_type = @config[:test_distribution].eql?('package') ? 'package' : 'class'
            { test_option_type => test_type }.merge(android_test_options)
          end
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
