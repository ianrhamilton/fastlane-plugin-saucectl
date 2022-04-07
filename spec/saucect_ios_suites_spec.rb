require_relative 'spec_helper'
require_relative '../lib/fastlane/plugin/saucectl/helper/ios_suites'

describe Fastlane::Saucectl::IosSuites do
  describe 'suites' do
    before do
      @config = {}
      ENV['JOB_NAME'] = 'unit-test'
      ENV['BUILD_NUMBER'] = '123'
    end

    it "should fail when user sets invalid kind of test framework for iOS" do
      @config[:platform] = 'ios'
      @config[:kind] = 'espresso'
      @config[:devices] = []
      expect { Fastlane::Saucectl::IosSuites.new(@config) }
        .to raise_error(StandardError, "❌ espresso is not a supported test framework for iOS. Use xcuitest")
    end

    it 'should raise an error when user does not specify device array' do
      @config[:platform] = 'ios'
      expect { Fastlane::Saucectl::IosSuites.new(@config) }
        .to raise_error(StandardError, "❌ For the ios platform you must specify `devices` array")
    end

    it 'should create an array of suites for each specified iPhone devices when user does not specify test_plan, test_target, or test_distribution method (i.e. executes tests from test runner)' do
      @config[:platform] = 'ios'
      @config[:kind] = 'xcuitest'
      @config[:devices] = [
        {
          name: 'iPhone One',
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
        {
          id: "iphone_two",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
      ]
      res = Fastlane::Saucectl::IosSuites.new(@config).generate
      expect(res.size).to eql(2)
    end

    it 'should create an array of suites for each specified iPhone devices based on specified test distribution type from test_target' do
      @config[:platform] = 'ios'
      @config[:kind] = 'xcuitest'
      @config[:test_target] = 'MyDemoAppUITests'
      @config[:test_distribution] = 'class'
      @config[:devices] = [
        {
          name: 'iPhone One',
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
        {
          id: "iphone_two",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
      ]
      res = Fastlane::Saucectl::IosSuites.new(@config).generate
      p res
      expect(res.size).to eql(6)
    end

    it 'should optionally shard user specified test_plan' do
        @config[:platform] = 'ios'
        @config[:kind] = 'xcuitest'
        @config[:test_plan] = 'EnabledUITests'
        @config[:test_distribution] = 'shard'
        @config[:devices] = [
          {
            name: 'iPhone One',
            orientation: 'portrait',
            device_type: 'phone',
            carrier_connectivity: false,
            deviceType: 'phone',
            private: true
          },
          {
            id: "iphone_two",
            orientation: 'portrait',
            device_type: 'phone',
            carrier_connectivity: false,
            deviceType: 'phone',
            private: true
          },
        ]

        res = Fastlane::Saucectl::IosSuites.new(@config).generate
        expect(res.size).to eql(2)
    end

    it 'should distribute tests based on the number of specified iphone devices' do
      @config[:platform] = 'ios'
      @config[:kind] = 'xcuitest'
      @config[:test_distribution] = 'shard'
      @config[:test_target] = 'MyDemoAppUITests'
      @config[:devices] = [
        {
          name: 'iPhone One',
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
        {
          id: "iphone_two",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
      ]
      actual_test_options = Fastlane::Saucectl::IosSuites.new(@config).generate
      expect(actual_test_options.size).to eql(2)
    end

    it 'should create a iOS specific hash key value pairs' do
      @config[:platform] = 'ios'
      @config[:kind] = 'xcuitest'
      @config[:test_target] = 'MyDemoAppUITests'
      @config[:devices] = [
        {
          name: 'iPhone One',
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
        {
          id: "iphone_two",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
      ]
      expected_test_options = { "class" => "SomeTestClass1" }
      actual_test_options = Fastlane::Saucectl::IosSuites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'should return real device test options' do
      @config[:platform] = 'ios'
      @config[:kind] = 'xcuitest'
      @config[:test_target] = 'MyDemoAppUITests'
      @config[:devices] = [
        {
          name: 'iPhone One',
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
        {
          id: "iphone_two",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
      ]
      expected_test_options = { "class" => "SomeTestClass1" }
      actual_test_options = Fastlane::Saucectl::IosSuites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it "should fail when user attempts to set by size when on iOS platform" do
      @config[:platform] = 'ios'
      @config[:kind] = 'xcuitest'
      @config[:size] = '@SmallTest'
      @config[:devices] = [
        {
          name: 'iPhone One',
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
        {
          id: "iphone_two",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
      ]
      expect { Fastlane::Saucectl::IosSuites.new(@config).generate }
        .to raise_error(StandardError, "❌ execution by size is not supported on the iOS platform!")
    end

    it "should fail when user attempts to set by annotation when on iOS platform" do
      @config[:platform] = 'ios'
      @config[:kind] = 'xcuitest'
      @config[:annotation] = 'com.android.buzz.MyAnnotation'
      @config[:kind] = 'xcuitest'
      @config[:devices] = [
        {
          name: 'iPhone One',
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
        {
          id: "iphone_two",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
      ]
      expect { Fastlane::Saucectl::IosSuites.new(@config).generate }
        .to raise_error(StandardError, "❌ execution by annotation is not supported on the iOS platform!")
    end
  end
end
