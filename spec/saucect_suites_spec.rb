require_relative 'spec_helper'
require_relative '../lib/fastlane/plugin/saucectl/helper/suites'

describe Fastlane::Saucectl::Suites do
  describe 'suites' do
    before do
      @config = {}
      ENV['JOB_NAME'] = 'unit-test'
      ENV['BUILD_NUMBER'] = '123'
    end

    it "should fail when user sets invalid kind of test framework for iOS" do
      @config[:platform] = 'ios'
      @config[:kind] = 'espresso'
      expect { Fastlane::Saucectl::Suites.new(@config).check_kind }
        .to raise_error(StandardError, "❌ espresso is not a supported test framework for iOS. Use xcuitest")
    end

    it "should fail when user sets invalid kind of test framework for android" do
      @config[:platform] = 'android'
      @config[:kind] = 'xcuitest'
      expect { Fastlane::Saucectl::Suites.new(@config).check_kind }
        .to raise_error(StandardError, "❌ xcuitest is not a supported test framework for android. Use espresso")
    end

    it 'should raise an error when user does not specify device array' do
      @config[:platform] = 'ios'
      expect { Fastlane::Saucectl::Suites.new(@config).is_ios_reqs_satisfied? }
        .to raise_error(StandardError, "❌ For ios you must specify test_target or test_plan")
    end

    it 'should optionally instruct saucectl execute user specified test classes' do
      @config[:test_distribution] = %w[com.test.SomeClass1 com.test.SomeClass2 com.test.SomeClass3]
      @config[:platform] = 'android'
      expected_class_arr = %w[com.test.SomeClass1 com.test.SomeClass2 com.test.SomeClass3]
      actual_class_arr = Fastlane::Saucectl::Suites.new(@config).test_distribution_array
      expect(expected_class_arr).to eql(actual_class_arr)
    end

    it 'should create suite name from jenkins data' do
      ENV['JOB_NAME'] = 'myFakeJenkinsJob'
      ENV['BUILD_NUMBER'] = '1000'
      suite_name = Fastlane::Saucectl::Suites.new(@config).suite_name('someTestClass')
      expect(suite_name).to eql('myFakeJenkinsJob-1000-someTestClass')
    end

    it 'android: should create suite name from test type name if jenkins data not available' do
      ENV['JOB_NAME'] = nil
      ENV['BUILD_NUMBER'] = nil
      @config[:kind] = 'espresso'
      suite_name = Fastlane::Saucectl::Suites.new(@config).suite_name('someTestClass')
      expect(suite_name).to eql('espresso-someTestClass')
    end

    it 'android: should allow users to specify an array of virtual devices' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:emulators] = [
        {
          name: "Android GoogleApi Emulator",
          platform_versions: %w[12.3 11.1],
          orientation: 'portrait'
        },
        {
          name: "Android GoogleApi Emulator 2",
          platform_versions: %w[12.3 11.1],
          orientation: 'portrait'
        }
      ]
      res = Fastlane::Saucectl::Suites.new(@config).create_virtual_device_suites
      expect(res.is_a?(Array)).to be_truthy
    end

    it 'should create an array of suites for virtual devices based on default test distribution type (class)' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:emulators] = [
        {
          name: "Android GoogleApi Emulator",
          platform_versions: %w[12.3 11.1],
          orientation: 'portrait'
        }
      ]
      res = Fastlane::Saucectl::Suites.new(@config).create_virtual_device_suites
      expect(res.is_a?(Array)).to be_truthy
    end

    it 'should create an array of suites for each specified real devices based on specified test distribution type' do
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:carrier_connectivity] = false
      @config[:private] = true
      @config[:device_type] = 'phone'
      @config[:devices] = [
        {
          name: "Some Android Device",
          platform_versions: %w[12.3 11.1],
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone'

        },
        {
          id: "android_googleApi_Emulator",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone'
        },
      ]
      device_suite = Fastlane::Saucectl::Suites.new(@config).create_real_device_suites
      expect(device_suite.is_a?(Array)).to be_truthy
    end

    it 'should create a android specific hash key value pairs when testing on android' do
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:carrier_connectivity] = false
      @config[:test_distribution] = 'class'
      @config[:clear_data] = true
      @config[:use_test_orchestrator] = true
      @config[:devices] = [
        {
          name: "Some Android Device",
          platform_versions: %w[12.3 11.1],
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone'

        }
      ]
      expected_test_options = { "class" => "SomeTestClass1", "clearPackageData" => true, "useTestOrchestrator" => true }
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'android: should not include android values when testing on ios platform' do
      @config[:platform] = 'ios'
      @config[:kind] = 'xcuitest'
      expected_test_options = { "class" => "SomeTestClass1" }
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'should return real device values when testing on real device platform' do
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:device_type] = 'phone'
      @config[:test_distribution] = 'class'
      @config[:clear_data] = true
      @config[:use_test_orchestrator] = true
      @config[:devices] = [
        {
          name: "Some Android Device",
          platform_versions: %w[12.3 11.1],
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone'
        }
      ]
      expected_test_options = { "class" => "SomeTestClass1", "clearPackageData" => true, "useTestOrchestrator" => true }
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'should raise an error when user attempts to shard test cases with a single emulator' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:shards] = 5
      @config[:test_distribution] = 'shard'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:emulators] = [
        {
          name: "Android GoogleApi Emulator",
          platform_versions: %w[11.1 13.0],
          orientation: 'portrait'
        }
      ]
      expect { Fastlane::Saucectl::Suites.new(@config).create_virtual_device_suites }
        .to raise_error(StandardError, "❌ Cannot split #{@config[:test_distribution]}'s across virtual devices with a single emulator. \nPlease specify a minimum of two devices!")
    end

    it 'should distribute an array of test cases to virtual devices suites based on number of specified shards' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:shards] = 5
      @config[:test_distribution] = 'shard'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:emulators] = [
        {
          name: "Android GoogleApi Emulator",
          platform_versions: %w[11.1 11.3],
          orientation: 'portrait'
        },
        {
          name: "Android GoogleApi Emulator 2",
          platform_versions: %w[11.1 11.3],
          orientation: 'portrait'
        }
      ]

      Fastlane::Saucectl::Suites.new(@config).create_virtual_device_suites
    end

    it 'android: should distribute tests based on the number of specified real devices suites' do
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:devices] = [
        {
          name: 'Device One',
          platform_version: '11.1',
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
        {
          id: "device_two",
          orientation: 'portrait',
          device_type: 'phone',
          carrier_connectivity: false,
          deviceType: 'phone',
          private: true
        },
      ]
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:test_distribution] = 'shard'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).create_real_device_suites
      expect(actual_test_options.size).to eql(2)
    end

    it 'should create an array of suites for each specified iPhone devices based on specified test distribution type' do
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
      res = Fastlane::Saucectl::Suites.new(@config).create_real_device_suites
      expect(res.is_a?(Array)).to be_truthy
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
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'should return real device test options when testing on real device platform' do
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
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'should distribute tests based on the number of specified iphone devices suites' do
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
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).create_real_device_suites
      expect(actual_test_options.size).to eql(2)
    end
  end
end
