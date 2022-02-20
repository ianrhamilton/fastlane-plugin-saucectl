require_relative 'spec_helper'
require 'yaml'

describe Fastlane::Actions::SauceConfigAction do
  describe 'saucelabs config action' do

    after do
      # FileUtils.rm_rf('.sauce')
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"-", "build"=>"Release "}}, "espresso"=>{"app"=>File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"espresso-logintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>["10.0", "11.0"]}]}, {"name"=>"espresso-webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>["10.0", "11.0"]}]}]}
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"-", "build"=>"Release "}}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"espresso-logintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-logintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"-", "build"=>"Release "}}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"espresso-logintest#nocredentiallogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-logintest#nousernamelogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-logintest#nopasswordlogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-logintest#succesfullogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-webviewtest#withouturltest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-webviewtest#webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-logintest#nocredentiallogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-logintest#nousernamelogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-logintest#nopasswordlogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-logintest#succesfullogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-webviewtest#withouturltest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-webviewtest#webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"-", "build"=>"Release "}}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"espresso-shard 1", "testOptions"=>{"class"=>["com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest"], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"device one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"espresso-shard 2", "testOptions"=>{"class"=>["com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest"], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"device_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create config.yml file for real ios devices' do
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"-", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"xcuitest-my_demo_appuitests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"xcuitest-my_demo_othertests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests"}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"xcuitest-my_demo_appuitests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_AppUITests"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"xcuitest-my_demo_othertests", "testOptions"=>{"class"=>"MyDemoAppUITests.My_Demo_OtherTests"}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file for ios real devices with test distribution method as shard' do
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"-", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"xcuitest-shard 1", "testOptions"=>{"class"=>["MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetails", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart"]}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"xcuitest-shard 2", "testOptions"=>{"class"=>["MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateCartToCatalog", "MyDemoAppUITests.My_Demo_OtherTests/testOne", "MyDemoAppUITests.My_Demo_OtherTests/testTwo", "MyDemoAppUITests.My_Demo_OtherTests/testThree", "MyDemoAppUITests.My_Demo_OtherTests/testFour", "MyDemoAppUITests.My_Demo_OtherTests/testFive"]}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
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

    it 'should create real device config.yml file based on xcode test target' do
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"-", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"xcuitest-shard 1", "testOptions"=>{"class"=>["MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetails", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart"]}, "devices"=>[{"name"=>"iphone one", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}, {"name"=>"xcuitest-shard 2", "testOptions"=>{"class"=>["MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateCartToCatalog", "MyDemoAppUITests.My_Demo_OtherTests/testOne", "MyDemoAppUITests.My_Demo_OtherTests/testTwo", "MyDemoAppUITests.My_Demo_OtherTests/testThree", "MyDemoAppUITests.My_Demo_OtherTests/testFour", "MyDemoAppUITests.My_Demo_OtherTests/testFive"]}, "devices"=>[{"id"=>"iphone_two", "orientation"=>"portrait", "options"=>{"deviceType"=>"PHONE", "private"=>false}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file based on xcode test plan' do
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
      p config
      # expected_config = { "apiVersion" => "v1alpha", "kind" => "xcuitest", "retries" => 0, "sauce" => { "region" => "eu-central-1", "concurrency" => 1, "metadata" => { "name" => "testing/ios-ui-test-quarantine-15", "build" => "Release " } }, "xcuitest" => { "app" => "/Users/ian.hamilton/Documents/workspace/fastlane-plugin-rsaucectl/my-demo-app-ios/MyTestApp.ipa", "testApp" => "/Users/ian.hamilton/Documents/workspace/fastlane-plugin-rsaucectl/my-demo-app-ios/MyTestAppRunner.ipa" }, "artifacts" => { "download" => { "when" => "always", "match" => ["junit.xml"], "directory" => "./artifacts/" } }, "reporters" => { "junit" => { "enabled" => true } }, "suites" => [{ "name" => "testing/ios-ui-test-quarantine-15-shard 1", "testOptions" => { "class" => ["MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetails", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart", "MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart"] }, "devices" => [{ "name" => "iphone one", "orientation" => "portrait", "options" => { "deviceType" => "PHONE", "private" => false } }] }, { "name" => "testing/ios-ui-test-quarantine-15-shard 2", "testOptions" => { "class" => ["MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog", "MyDemoAppUITests.My_Demo_AppUITests/testNavigateCartToCatalog", "MyDemoAppUITests.My_Demo_OtherTests/testOne", "MyDemoAppUITests.My_Demo_OtherTests/testTwo", "MyDemoAppUITests.My_Demo_OtherTests/testThree", "MyDemoAppUITests.My_Demo_OtherTests/testFour", "MyDemoAppUITests.My_Demo_OtherTests/testFive"] }, "devices" => [{ "id" => "iphone_two", "orientation" => "portrait", "options" => { "deviceType" => "PHONE", "private" => false } }] }] }
      # expect(config).to eql expected_config
    end
  end
end
