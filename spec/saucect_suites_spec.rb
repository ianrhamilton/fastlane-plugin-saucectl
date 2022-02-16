require_relative 'spec_helper'
require_relative '../lib/fastlane/plugin/rsaucectl/helper/suites'

describe Fastlane::Saucectl::Suites do
  describe 'suites' do
    before do
      @config = {}
    end

    it 'should allow user to add devices array' do
      @config[:real_devices] = %w[device_one device_two device_three]
      device_array = Fastlane::Saucectl::Suites.new(@config).device_array
      expect(device_array).to eql(@config[:real_devices])
    end

    it 'should raise an error when user does not specify device array' do
      @config[:real_devices] = 'someDevice'
      expect { Fastlane::Saucectl::Suites.new(@config).device_array }
        .to raise_error(StandardError, "❌ Expected array of devices")
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

    it 'android: should create an array of suites for virtual devices based on specified test distribution type' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:is_virtual_device] = true
      res = Fastlane::Saucectl::Suites.new(@config).create_virtual_device_suites
      expect(res.is_a?(Array)).to be_truthy
    end

    it 'android: should allow users to specify an array of virtual devices' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:is_virtual_device] = true
      @config[:virtual_device_name] = %w[device_one device_two device_three]
      res = Fastlane::Saucectl::Suites.new(@config).create_virtual_device_suites
      expect(res.is_a?(Array)).to be_truthy
    end

    it 'android: should create an array of suites for virtual devices based on specified test distribution type' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:is_virtual_device] = true
      @config[:platform_version] = %w[10.0 11.0]
      res = Fastlane::Saucectl::Suites.new(@config).create_virtual_device_suites
      expect(res.is_a?(Array)).to be_truthy
    end

    it 'android: should create an array of suites for virtual devices based on specified test distribution type' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:is_virtual_device] = true
      @config[:virtual_device_platform_version] = %w[10.0 11.0]
      res = Fastlane::Saucectl::Suites.new(@config).create_virtual_device_suites
      expect(res.is_a?(Array)).to be_truthy
    end

    it 'android: should create an array of suites for each specified real devices based on specified test distribution type' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:real_devices] = %w[device_one device_two device_three]
      @config[:platform] = 'android'
      res = Fastlane::Saucectl::Suites.new(@config).create_real_device_suites
      expect(res.is_a?(Array)).to be_truthy
    end

    it 'android: should create a android specific hash key value pairs when testing on android' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:is_virtual_device] = true
      expected_test_options = { "class"=>"SomeTestClass1", "clearPackageData"=>true, "useTestOrchestrator"=>true }
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'android: should not include android values when testing on ios platform' do
      @config[:platform] = 'ios'
      expected_test_options = { "class"=>"SomeTestClass1" }
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'android: should return real device values when testing on real device platform' do
      @config[:platform] = 'android'
      @config[:real_devices] = %w[device_one device_two device_three]
      expected_test_options = {"class"=>"SomeTestClass1", "clearPackageData"=>true, "useTestOrchestrator"=>true}
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'android: should distribute an array of test cases to virtual devices suites based on number of specified shards' do
      @config[:platform] = 'android'
      @config[:shards] = 5
      @config[:test_distribution] = 'shard'
      @config[:is_virtual_device] = true
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).create_virtual_device_suites
      expect(actual_test_options.size).to eql(6)
    end

    it 'android: should raise an error when user attempts to shard real device suites' do
      @config[:platform] = 'android'
      @config[:shards] = 3
      @config[:test_distribution] = 'shard'
      @config[:is_virtual_device] = false
      @config[:real_devices] = ['Device One', "device_two", "device_three"]
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      expect { Fastlane::Saucectl::Suites.new(@config).create_real_device_suites }
        .to raise_error(StandardError, "❌ sharding is not supported for real devices")
    end

    it 'android: should raise an error when user specifies invalid device type' do
      @config[:platform] = 'android'
      @config[:device_type] = 'foo'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      expect { Fastlane::Saucectl::Suites.new(@config).device_type }
        .to raise_error(StandardError, "❌ foo is not a recognised device type")
    end

    it 'ios: should create an array of suites for each specified real devices based on specified test distribution type' do
      @config[:real_devices] = %w[device_one device_two device_three]
      @config[:platform] = 'ios'
      @config[:test_target] = 'MyDemoAppUITests'
      res = Fastlane::Saucectl::Suites.new(@config).create_real_device_suites
      expect(res.is_a?(Array)).to be_truthy
    end

    it 'ios should create a IOS specific hash key value pairs' do
      @config[:platform] = 'ios'
      @config[:test_target] = 'MyDemoAppUITests'
      expected_test_options = { "class"=>"SomeTestClass1" }
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'should return real device values when testing on real device platform' do
      @config[:platform] = 'ios'
      @config[:test_target] = 'MyDemoAppUITests'
      @config[:real_devices] = %w[device_one device_two device_three]
      expected_test_options = {"class"=>"SomeTestClass1" }
      actual_test_options = Fastlane::Saucectl::Suites.new(@config).default_test_options('SomeTestClass1')
      expect(actual_test_options).to eql(expected_test_options)
    end

    it 'android: should raise an error when user attempts to shard real device suites' do
      @config[:shards] = 3
      @config[:test_distribution] = 'shard'
      @config[:platform] = 'ios'
      @config[:test_target] = 'MyDemoAppUITests'
      @config[:real_devices] = %w[device_one device_two device_three]
      expect { Fastlane::Saucectl::Suites.new(@config).create_real_device_suites }
        .to raise_error(StandardError, "❌ sharding is not supported for real devices")
    end
  end
end
