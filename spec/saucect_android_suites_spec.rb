require_relative 'spec_helper'
require_relative '../lib/fastlane/plugin/saucectl/helper/android_suites'

describe Fastlane::Saucectl::AndroidSuites do
  describe 'suites' do
    before do
      @config = {}
      ENV['JOB_NAME'] = 'unit-test'
      ENV['BUILD_NUMBER'] = '123'
    end

    it "should fail when user sets invalid kind of test framework for android" do
      @config[:platform] = 'android'
      @config[:kind] = 'xcuitest'
      expect { Fastlane::Saucectl::AndroidSuites.new(@config) }
        .to raise_error(StandardError, "❌ xcuitest is not a supported test framework for android. Use espresso")
    end

    it "should raise an error when user does not specify path to tests when executing by test distribution with class" do
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:test_distribution] = 'class'
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
      expect { Fastlane::Saucectl::AndroidSuites.new(@config).generate }
        .to raise_error(StandardError, "❌ to distribute tests you must specify the path to your espresso tests. For example `path_to_tests:someModule/src/androidTest`")
    end

    it 'should optionally instruct saucectl execute user specified test classes' do
      @config[:test_class] = %w[com.test.SomeClass1 com.test.SomeClass2 com.test.SomeClass3]
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      expected_class_arr = %w[com.test.SomeClass1 com.test.SomeClass2 com.test.SomeClass3]
      actual_class_arr = Fastlane::Saucectl::AndroidSuites.new(@config).test_distribution_array
      expect(expected_class_arr).to eql(actual_class_arr)
    end

    it 'should create suite name from jenkins data' do
      ENV['JOB_NAME'] = 'myFakeJenkinsJob'
      ENV['BUILD_NUMBER'] = '1000'
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      suite_name = Fastlane::Saucectl::AndroidSuites.new(@config).suite_name('someTestClass')
      expect(suite_name).to eql('myFakeJenkinsJob-1000-someTestClass')
    end

    it 'should create suite name from test type name if jenkins data not available' do
      ENV['JOB_NAME'] = nil
      ENV['BUILD_NUMBER'] = nil
      @config[:kind] = 'espresso'
      suite_name = Fastlane::Saucectl::AndroidSuites.new(@config).suite_name('someTestClass')
      expect(suite_name).to eql('espresso-someTestClass')
    end

    it 'should allow users to specify an array of virtual devices' do
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
      res = Fastlane::Saucectl::AndroidSuites.new(@config).generate
      expect(res.is_a?(Array)).to be_truthy
    end

    it 'should create an array of suites for virtual devices based on default test distribution type (class)' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:test_distribution] = 'class'
      @config[:emulators] = [
        {
          name: "Android GoogleApi Emulator",
          platform_versions: %w[12.3 11.1],
          orientation: 'portrait'
        }
      ]
      res = Fastlane::Saucectl::AndroidSuites.new(@config).generate
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
      device_suite = Fastlane::Saucectl::AndroidSuites.new(@config).create_test_distribution_suite
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
      expected_test_options = { "class" => "com.saucelabs.mydemoapp.android.view.activities.LoginTest", "clearPackageData" => true, "useTestOrchestrator" => true }
      actual_test_options = Fastlane::Saucectl::AndroidSuites.new(@config).generate
      expect(actual_test_options[0]['testOptions']).to eql(expected_test_options)
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
      expected_test_options = { "class" => "com.saucelabs.mydemoapp.android.view.activities.LoginTest", "clearPackageData" => true, "useTestOrchestrator" => true }
      actual_test_options = Fastlane::Saucectl::AndroidSuites.new(@config).generate
      expect(actual_test_options[0]['testOptions']).to eql(expected_test_options)
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
      expect { Fastlane::Saucectl::AndroidSuites.new(@config).generate }
        .to raise_error(StandardError, "❌ Cannot split #{@config[:test_distribution]}'s across devices with a single device/emulator. \nPlease specify a minimum of two devices/emulators!")
    end

    it 'should distribute an array of test cases to virtual devices suites based on number of specified shards' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:shards] = 5
      @config[:test_distribution] = 'shard'
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

      actual_test_options = Fastlane::Saucectl::AndroidSuites.new(@config).generate
      expect(actual_test_options.size).to eql(2)
    end

    it 'should distribute tests based on the number of specified real devices suites' do
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:test_distribution] = 'shard'
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

      actual_test_options = Fastlane::Saucectl::AndroidSuites.new(@config).generate
      expect(actual_test_options.size).to eql(2)
    end

    it 'should distribute to real devices by size' do
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:size] = '@SmallTest'
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

      actual_test_options = Fastlane::Saucectl::AndroidSuites.new(@config).create_test_distribution_suite
      expect(actual_test_options[0]['testOptions']['size']).to eql("@SmallTest")
    end

    it 'should distribute to real devices by annotation' do
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:annotation] = 'com.android.buzz.MyAnnotation'
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
      actual_test_options = Fastlane::Saucectl::AndroidSuites.new(@config).create_test_distribution_suite
      expect(actual_test_options[0]['testOptions']['annotation']).to eql('com.android.buzz.MyAnnotation')
    end
  end
end
