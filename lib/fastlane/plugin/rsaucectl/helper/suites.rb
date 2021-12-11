require 'base64'
require_relative 'android_test_plan'
require_relative 'file_utils'
require_relative 'ios_test_plan'

module Fastlane
  module Saucectl
    #
    # This class will create test suites based on user specified configuration properties
    #
    class Suites
      include FileUtils

      def initialize(config)
        @config = config
      end

      def device_array
        if @config['real_devices'].kind_of?(String)
          @config['real_devices'] = File.read(@config['real_devices'].to_s)
        else
          @config['real_devices']
        end
      end

      def test_plan
        if @config['platform'].casecmp('ios').zero?
          Fastlane::Saucectl::AppleTestPlan.new(@config)
        else
          Fastlane::Saucectl::AndroidTestPlan.new(@config)
        end
      end

      def test_distribution_array
        if @config['test_distribution'].kind_of?(Array)
          @config['test_distribution']
        else
          test_plan.test_distribution
        end
      end

      def suite_name(test_type)
        if ENV['JOB_NAME'].nil? && ENV['BUILD_NUMBER'].nil?
          "#{@config['kind']}-#{test_type.split('.')[-1]}"
        else
          "#{ENV['JOB_NAME']}-#{ENV['BUILD_NUMBER']}-#{test_type.split('.')[-1]}"
        end
      end

      def create_virtual_device_suites
        if @config['test_distribution'] == 'shard'
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
        shards = arr.each_slice((arr.size / @config['shards'].to_f).round).to_a
        shards.each_with_index do |suite, i|
          test_suites << {
            'name' => suite_name("shard #{i}").downcase,
            'testOptions' => default_test_options(suite)
          }.merge(device_type_values)
        end
        test_suites
      end

      def shard_real_device_suites
        arr = test_distribution_array
        shards = arr.each_slice((arr.size / device_array.size.to_f).round).to_a
        test_suites = []
        device_array.each_with_index do |device, i|
          test_suites << {
            'name' => suite_name("shard #{i}").downcase,
            'testOptions' => default_test_options(shards[i])
          }.merge(device_type_values(device))
        end
        test_suites
      end

      def create_real_device_suites
        if @config['test_distribution'] == 'shard'
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
        @config['is_virtual_device'] ? virtual_device_options : real_device_options(name)
      end

      def virtual_device_options
        platform_versions = if @config['virtual_device_platform_version'].nil?
                              '11.0'
                            else
                              @config['virtual_device_platform_version'].join(',')
                            end
        {
          'emulators' => [{
                            'name' => @config['virtual_device_name'],
                            'orientation' => @config['orientation'] || 'portrait',
                            'platformVersions' => platform_versions.split(',')
                          }]
        }
      end

      def real_device_options(name)
        device_type_key = name.include?('_') ? 'id' : 'name'
        { 'devices' => [{
                          device_type_key => name, 'orientation' => 'portrait'
                        }.merge('options' => device_type.merge(cloud_type))] }
      end

      def default_test_options(test_type)
        test_option_type = @config['test_distribution'] == 'package' ? 'package' : 'class'
        if @config['platform'] == 'android'
          { test_option_type => test_type }.merge(android_test_options)
        else
          { 'class' => test_type }
        end
      end

      def android_test_options
        {
          'clearPackageData' => @config['clearPackageData'] || true,
          'useTestOrchestrator' => @config['useTestOrchestrator'] || true
        }
      end

      def device_type
        device_types = %w[ANY TABLET PHONE any tablet phone]
        unless @config['device_type'].nil? || device_types.include?(@config['device_type'])
          raise "#{@config['device_type']} is not a recognised device type"
        end

        device_type = @config['device_type'].nil? ? 'phone' : @config['device_type']
        { 'deviceType' => device_type.upcase }
      end

      def cloud_type
        type = !(@config['private'].nil? || @config['private'] == false)
        { 'private' => type }
      end
    end
  end
end
