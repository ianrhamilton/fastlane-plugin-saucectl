require_relative 'spec_helper'
require 'yaml'

describe Fastlane::Actions::SauceConfigAction do
  describe 'saucelabs config action' do

    before do
      ENV['JOB_NAME'] = 'unit-test'
      ENV['BUILD_NUMBER'] = '123'
    end

    after do
      FileUtils.rm_rf('.sauce')
    end

    it 'should create config.yml file for android espresso based on user specified virtual device configurations' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app_path: '#{File.expand_path("my-demo-app-android")}',
                         app_name: 'myTestApp.apk',
                         test_runner_app: 'myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'class',
                         is_virtual_device: true
          })
        end").runner.execute(:test)

      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "espresso"=>{"app"=>File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-logintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>["10.0", "11.0"]}]}, {"name"=>"unit-test-123-webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>["10.0", "11.0"]}]}]}
      expect(config).to eql expected_config
    end

    it 'should create config.yml file for android espresso based on user specified real device configurations' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app_path: '#{File.expand_path("my-demo-app-android")}',
                         app_name: 'myTestApp.apk',
                         test_runner_app: 'myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'class',
                         real_devices: ['device one', 'device_two']
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-logintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-logintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'android: should create real device config.yml file with test distribution method as testCase' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app_path: '#{File.expand_path("my-demo-app-android")}',
                         app_name: 'myTestApp.apk',
                         test_runner_app: 'myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'testCase',
                         real_devices: ['device one', 'device_two']
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-logintest#nocredentiallogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-logintest#nousernamelogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-logintest#nopasswordlogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-logintest#succesfullogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-webviewtest#withouturltest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-webviewtest#webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-logintest#nocredentiallogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-logintest#nousernamelogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-logintest#nopasswordlogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-logintest#succesfullogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-webviewtest#withouturltest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-webviewtest#webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'android: should create real device config.yml file with test distribution method as shard' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app_path: '#{File.expand_path("my-demo-app-android")}',
                         app_name: 'myTestApp.apk',
                         test_runner_app: 'myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'shard',
                         real_devices: ['device one', 'device_two']
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-shard 1", "testOptions"=>{"class"=>["com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest"], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-shard 2", "testOptions"=>{"class"=>["com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest"], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should raise an error when user specifies invalid test kind for android platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-android")}',
                         app_name: 'myTestApp.apk',
                         test_runner_app: 'myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'shard',
                         real_devices: ['device one', 'device_two']
          })
        end").runner.execute(:test)
      end.to raise_error('❌ xcuitest is not a supported test framework for android. Use espresso')
    end

    it 'should raise an error when user does not specify a device array for android platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app_path: '#{File.expand_path("my-demo-app-android")}',
                         app_name: 'myTestApp.apk',
                         test_runner_app: 'myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'testCase'
          })
        end").runner.execute(:test)
      end.to raise_error('❌ Expected array of devices')
    end

    it ' should raise an error when user does not specify a testPlan or testTarget for ios platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         real_devices: ['iphone one', 'iphone_two'],
                         test_distribution: 'shard'
          })
        end").runner.execute(:test)
      end.to raise_error('❌ For ios you must specify test_target or test_plan')
    end

    it 'should raise an error when user specifies invalid test kind for ios platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'espresso',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         real_devices: ['iphone one', 'iphone_two'],
                         test_target: 'MyDemoAppUITests',
                         test_distribution: 'shard',
          })
        end").runner.execute(:test)
      end.to raise_error('❌ espresso is not a supported test framework for iOS. Use xcuitest')
    end

    it 'should create config.yml file for real ios devices using xcode test target' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         real_devices: ['iphone one', 'iphone_two'],
                         test_target: 'MyDemoAppUITests'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-my_demo_appuitests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file based on xcode test target using default distribution method (class)' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         real_devices: ['iphone one', 'iphone_two'],
                         test_target: 'MyDemoAppUITests'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-my_demo_appuitests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file for ios real devices using xcode test target and distribution method set as shard' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         real_devices: ['iphone one', 'iphone_two'],
                         test_target: 'MyDemoAppUITests',
                         test_distribution: 'shard',
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-shard 1", "testOptions"=>{"class"=>["MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetails", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart"]}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-shard 2", "testOptions"=>{"class"=>["MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateCartToCatalog", "MyDemoAppUITests.My_Demo_OtherTests/testOne", "MyDemoAppUITests.My_Demo_OtherTests/testTwo", "MyDemoAppUITests.My_Demo_OtherTests/testThree", "MyDemoAppUITests.My_Demo_OtherTests/testFour", "MyDemoAppUITests.My_Demo_OtherTests/testFive"]}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file for ios real devices using xcode test target and distribution method set as testCase' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         real_devices: ['iphone one', 'iphone_two'],
                         test_target: 'MyDemoAppUITests',
                         test_distribution: 'testCase',
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpageadditemtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpageaddmultipleitemstocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpagedefault", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetails", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetails"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsprice", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailshighlights", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsdecreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsincreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsdefaultcolor", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailscolorsswitch", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsratesselection", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsaddtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsproceedtocheckout", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatetocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatetomore", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretowebview", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretoabout", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretoqrcode", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretogeolocation", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretodrawing", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatefromcarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatecarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateCartToCatalog"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testone", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testOne"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testtwo", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testTwo"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testthree", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testThree"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testfour", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testFour"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testfive", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testFive"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpageadditemtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpageaddmultipleitemstocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpagedefault", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetails", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetails"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsprice", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailshighlights", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsdecreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsincreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsdefaultcolor", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailscolorsswitch", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsratesselection", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsaddtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsproceedtocheckout", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatetocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatetomore", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretowebview", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretoabout", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretoqrcode", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretogeolocation", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretodrawing", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatefromcarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatecarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateCartToCatalog"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testone", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testOne"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testtwo", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testTwo"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testthree", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testThree"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testfour", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testFour"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testfive", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testFive"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file based on xcode test plan using default distribution method (class)' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         real_devices: ['iphone one', 'iphone_two'],
                         test_plan: 'UITests'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")

      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa") }, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-my_demo_appuitests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file based on xcode test plan using sharding distribution method' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         real_devices: ['iphone one', 'iphone_two'],
                         test_plan: 'UITests',
                         test_distribution: 'shard'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")

      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-shard 1", "testOptions"=>{"class"=>["MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetails", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart"]}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-shard 2", "testOptions"=>{"class"=>["MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog", "MyDemoAppUITests.My_Demo_OtherTests/testFour", "MyDemoAppUITests.My_Demo_OtherTests/testFive"]}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file based on xcode test plan using testCase distribution method' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         real_devices: ['iphone one', 'iphone_two'],
                         test_plan: 'UITests',
                         test_distribution: 'testCase'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpageadditemtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpageaddmultipleitemstocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpagedefault", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetails", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetails"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsprice", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailshighlights", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsdecreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsincreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsdefaultcolor", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailscolorsswitch", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsratesselection", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsaddtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsproceedtocheckout", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatetocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatetomore", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretowebview", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretoabout", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretoqrcode", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretogeolocation", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretodrawing", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatefromcarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testfour", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testFour"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testfive", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testFive"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpageadditemtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpageaddmultipleitemstocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductlistingpagedefault", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetails", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetails"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsprice", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailshighlights", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsdecreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsincreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsdefaultcolor", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailscolorsswitch", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsratesselection", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsaddtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testproductdetailsproceedtocheckout", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatetocart", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatetomore", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretowebview", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretoabout", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretoqrcode", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretogeolocation", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatemoretodrawing", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_appuitests/testnavigatefromcarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testfour", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testFour"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"unit-test-123-my_demo_othertests/testfive", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests/testFive"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should raise an error when user specifies virtual device option' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app_path: '#{File.expand_path("my-demo-app-ios")}',
                         app_name: 'MyTestApp.ipa',
                         test_runner_app: 'MyTestAppRunner.ipa',
                         region: 'eu',
                         test_target: 'MyDemoAppUITests',
                         is_virtual_device: true,
                         virtual_device_name: 'iPhone Simulator',
                         test_distribution: 'shard',
          })
        end").runner.execute(:test)
        end.to raise_error('❌ Sauce Labs platform does not support virtual device execution for ios apps')
    end
  end
end
