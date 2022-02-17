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

      def device_array
        UI.user_error!("❌ Expected array of devices") unless @config[:real_devices].kind_of?(Array)
        @config[:real_devices]
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
        if @config[:test_distribution].kind_of?(Array)
          @config[:test_distribution]
        else
          create_test_plan.test_distribution
        end
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
        else
          test_suites = []
          test_distribution_array.each do |test_type|
            test_suites << {
              'name' => suite_name(test_type).downcase,
              'testOptions' => default_test_options(test_type)
            }.merge(device_type_values)
          end
          test_suites
        end
      end

      def shard_virtual_device_suites
        test_suites = []
        arr = test_distribution_array
        shards = arr.each_slice((arr.size / @config[:shards].to_f).round).to_a
        shards.each_with_index do |suite, i|
          test_suites << {
            'name' => suite_name("shard #{i + 1}").downcase,
            'testOptions' => default_test_options(suite)
          }.merge(device_type_values)
        end
        test_suites
      end

      def shard_real_device_suites
        test_suites = []
        arr = test_distribution_array
        shards = arr.each_slice((arr.size / @config[:real_devices].size.to_f).round).to_a
        shards.each_with_index do |suite, i|
          test_suites << {
            'name' => suite_name("shard #{i + 1}").downcase,
            'testOptions' => default_test_options(suite)
          }.merge(device_type_values(device_array[i]))
        end
        test_suites
      end

      def create_real_device_suites
        if @config[:test_distribution] == 'shard'
          shard_real_device_suites
        else
          test_suites = []
          device_array.each do |device_name|
            test_distribution_array.each do |test_type|
              test_suites << {
                'name' => suite_name(test_type).downcase,
                'testOptions' => default_test_options(test_type)
              }.merge(device_type_values(device_name))
            end
          end
          test_suites
        end
      end

      def device_type_values(name = nil)
        @config[:is_virtual_device] ? virtual_device_options : real_device_options(name)
      end

      def virtual_device_options
        { 'emulators' => emulator }
      end

      def emulator
        emulators = []
        @config[:virtual_device_name].to_ary.each do |emulator|
          emulators << { 'name' => emulator,
                         'orientation' => @config[:orientation],
                         'platformVersions' => %w[10.0 11.0] }
        end
        emulators
      end

      def real_device_options(name)
        device_type_key = name.include?('_') ? 'id' : 'name'
        { 'devices' => [{
                          device_type_key => name, 'orientation' => 'portrait'
                        }.merge('options' => device_type.merge(cloud_type))] }
      end

      def default_test_options(test_type)
        test_option_type = @config[:test_distribution] == 'package' ? 'package' : 'class'
        if @config[:platform] == 'android'
          { test_option_type => test_type }.merge(android_test_options)
        else
          { 'class' => test_type }
        end
      end

      def android_test_options
        {
          'clearPackageData' => @config[:clear_data],
          'useTestOrchestrator' => @config[:use_test_orchestrator]
        }
      end

      def device_type
        device_types = %w[ANY TABLET PHONE any tablet phone]
        unless @config[:device_type].nil? || device_types.include?(@config[:device_type])
          UI.user_error!("❌ #{@config[:device_type]} is not a recognised device type")
        end

        device_type = @config[:device_type].nil? ? 'phone' : @config[:device_type]
        { 'deviceType' => device_type.upcase }
      end

      def cloud_type
        type = !(@config[:private].nil? || @config[:private] == false)
        { 'private' => type }
      end
    end
  end
end
