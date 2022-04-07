require_relative 'spec_helper'
require 'yaml'

describe Fastlane::Actions::SauceConfigAction do
  describe 'saucelabs runner action' do

    before do
      ENV['JOB_NAME'] = 'unit-test'
      ENV['BUILD_NUMBER'] = '123'
    end

    after do
      # FileUtils.rm_rf('.sauce')
    end

    it 'should raise an error when user does not specify devices or virtual devices on android platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({platform: 'android',
                        kind: 'espresso',
                        app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                        test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                        path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                        region: 'eu'
          })
        end").runner.execute(:test)
      end.to raise_error('❌ For android platform you must specify devices or emulators under test in order to execute tests')
    end

    it 'should raise an error when user does not specify devices on ios platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app: 'myTestApp.ipa',
                         test_app: 'myTestRunner.ipa',
                         region: 'eu'
          })
        end").runner.execute(:test)
      end.to raise_error('❌ For ios platform you must specify devices under test in order to execute tests')
    end

    it 'should create config.yml file for android espresso without setting test distribution and path to tests' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         region: 'eu',
                         emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: %w[10.0 11.0], orientation: 'portrait'}]
      })
    end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-Android GoogleApi Emulator", "testOptions"=>{"clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>%w[10.0 11.0]}]}]}
      expect(config).to eql expected_config
    end

    it 'should create config.yml file for virtual device configurations' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         region: 'eu',
                         emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: %w[10.0 11.0], orientation: 'portrait'}]
      })
    end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "espresso"=>{"app"=>File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=>File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-Android GoogleApi Emulator", "testOptions"=>{"clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>%w[10.0 11.0]}]}]}
      expect(config).to eql expected_config
    end

    it 'should allow android users to create config.yml file for virtual device configurations testing by size' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         size: '@LargeTest',
                         emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: %w[10.0 11.0], orientation: 'portrait'}]
      })
    end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-android googleapi emulator", "testOptions"=>{"size"=>"@LargeTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>%w[10.0 11.0]}]}]}
      expect(config).to eql expected_config
    end

    it 'should allow android users to execute tests by annotation on virtual devices' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         annotation: 'com.android.buzz.MyAnnotation',
                         emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: %w[10.0 11.0], orientation: 'portrait'}]
      })
    end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-android googleapi emulator", "testOptions"=>{"annotation"=>"com.android.buzz.MyAnnotation", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>%w[10.0 11.0]}]}]}
      expect(config).to eql expected_config
    end

    it 'should create config.yml file for android espresso based on user specified real device configurations' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'testCase',
                         devices: [ {name: 'RDC One', orientation: 'portrait', platform_version: '11.0'}]
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-com.saucelabs.mydemoapp.android.view.activities.logintest#nocredentiallogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}, "platformVersion"=>"11.0"}]}, {"name"=>"unit-test-123-com.saucelabs.mydemoapp.android.view.activities.logintest#nousernamelogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}, "platformVersion"=>"11.0"}]}, {"name"=>"unit-test-123-com.saucelabs.mydemoapp.android.view.activities.logintest#nopasswordlogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}, "platformVersion"=>"11.0"}]}, {"name"=>"unit-test-123-com.saucelabs.mydemoapp.android.view.activities.logintest#succesfullogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}, "platformVersion"=>"11.0"}]}, {"name"=>"unit-test-123-com.saucelabs.mydemoapp.android.view.activities.webviewtest#withouturltest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}, "platformVersion"=>"11.0"}]}, {"name"=>"unit-test-123-com.saucelabs.mydemoapp.android.view.activities.webviewtest#webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}, "platformVersion"=>"11.0"}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file for android platform with test distribution method as shard' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'shard',
                         devices: [ {name: 'RDC One', orientation: 'portrait', platform_version: '11.0'}, {name: 'RDC Two', orientation: 'portrait', platform_version: '11.0'}]
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-shard 1", "testOptions"=>{"class"=>["com.saucelabs.mydemoapp.android.view.activities.LoginTest"], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}, "platformVersion"=>"11.0"}]}, {"name"=>"unit-test-123-shard 2", "testOptions"=>{"class"=>["com.saucelabs.mydemoapp.android.view.activities.WebViewTest"], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"RDC Two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}, "platformVersion"=>"11.0"}]}]}
      expect(config).to eql expected_config
    end

    it 'should raise an error when user specifies invalid test kind for android platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'xcuitest',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'shard',
                         devices: [ {name: 'RDC One', orientation: 'portrait'}]
          })
        end").runner.execute(:test)
      end.to raise_error('❌ xcuitest is not a supported test framework for android. Use espresso')
    end

    it 'should raise an error when user specifies invalid test kind for ios platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                         test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}],
                         test_target: 'MyDemoAppUITests',
                         test_distribution: 'shard'
          })
        end").runner.execute(:test)
      end.to raise_error('❌ espresso is not a supported test framework for iOS. Use xcuitest')
    end

    it 'should create config.yml file for real ios devices using xcode test target' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                         test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_target: 'MyDemoAppUITests',
                         test_distribution: 'class'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-mydemoappuitests.navigationtest", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productlistingpagetest", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productlistingpagetest", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file for ios real devices using xcode test target and distribution method set as shard' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                         test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_target: 'MyDemoAppUITests',
                         test_distribution: 'shard',
          })
      end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{ "name"=>"unit-test-123-iphone rdc one-shard-1", "testOptions"=>{"class"=>%w[MyDemoAppUITests.NavigationTest MyDemoAppUITests.ProductDetailsTest]}, "devices"=>[{ "name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, { "name"=>"unit-test-123-iphone_rdc_two-shard-2", "testOptions"=>{ "class"=>["MyDemoAppUITests.ProductListingPageTest"]}, "devices"=>[{ "id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file for ios real devices using xcode test target and distribution method set as testCase' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                         test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_target: 'MyDemoAppUITests',
                         test_distribution: 'testCase'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "xcuitest"=>{"app"=>File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatetocart", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateToCart"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatetomore", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateToMore"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretowebview", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretoabout", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretoqrcode", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretogeolocation", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretodrawing", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatefromcarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatecarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateCartToCatalog"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetails", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetails"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsprice", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailshighlights", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsdecreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsincreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsdefaultcolor", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailscolorsswitch", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsratesselection", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsaddtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productlistingpagetest/testproductlistingpageadditemtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productlistingpagetest/testproductlistingpageaddmultipleitemstocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatetocart", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateToCart"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatetomore", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateToMore"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretowebview", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretoabout", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretoqrcode", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretogeolocation", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatemoretodrawing", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatefromcarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.navigationtest/testnavigatecarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateCartToCatalog"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetails", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetails"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsprice", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailshighlights", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsdecreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsincreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsdefaultcolor", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailscolorsswitch", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsratesselection", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productdetailstest/testproductdetailsaddtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productlistingpagetest/testproductlistingpageadditemtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-mydemoappuitests.productlistingpagetest/testproductlistingpageaddmultipleitemstocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file based on xcode test plan using sharding distribution method' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                         test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_plan: 'EnabledUITests',
                         test_distribution: 'shard'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "xcuitest"=>{"app"=>File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{ "name"=>"unit-test-123-iphone rdc one-shard-1", "testOptions"=>{"class"=>%w[MyDemoAppUITests.SomeSpec/testOne MyDemoAppUITests.SomeSpec/testTwo MyDemoAppUITests.SomeSpec/testThree]}, "devices"=>[{ "name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, { "name"=>"unit-test-123-iphone_rdc_two-shard-2", "testOptions"=>{ "class"=>%w[MyDemoAppUITests.SomeSpec/testFour MyDemoAppUITests.SomeSpec/testFive]}, "devices"=>[{ "id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create rdc config by xcode test plan' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                         test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                         test_plan: 'UITests'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "xcuitest"=>{"app"=>File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=>File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{ "name"=>"unit-test-123-uitests", "testOptions"=>{"class"=>%w[MyDemoAppUITests.NavigationTest/testNavigateToCart MyDemoAppUITests.NavigationTest/testNavigateToMore MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog MyDemoAppUITests.ProductDetailsTest/testProductDetails MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart]}, "devices"=>[{ "name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, { "name"=>"unit-test-123-uitests", "testOptions"=>{ "class"=>%w[MyDemoAppUITests.NavigationTest/testNavigateToCart MyDemoAppUITests.NavigationTest/testNavigateToMore MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog MyDemoAppUITests.ProductDetailsTest/testProductDetails MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart]}, "devices"=>[{ "id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}]}
      expect(config).to eql expected_config
    end

    it 'should allow users to specify an array of classes to execute on rdc' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}],
                         test_class: ['com.some.package.testing.SomeClassOne', 'com.some.package.testing.SomeClassTwo', 'com.some.package.testing.SomeClassThree', 'com.some.package.testing.SomeClassFour']
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{ "name"=>"unit-test-123-iphone rdc one", "testOptions"=>{ "class"=>%w[com.some.package.testing.SomeClassOne com.some.package.testing.SomeClassTwo com.some.package.testing.SomeClassThree com.some.package.testing.SomeClassFour], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{ "name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}]}
      expect(config).to eql expected_config
    end

    it 'should allow users to specify an array of classes to execute on virtual devices' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         emulators: [ {name: 'iPhone RDC One', platform_versions: ['11.0']}, {name: 'iPhone RDC Two', platform_versions: ['11.0']}],
                         test_class: ['com.some.package.testing.SomeClassOne', 'com.some.package.testing.SomeClassTwo', 'com.some.package.testing.SomeClassThree', 'com.some.package.testing.SomeClassFour']
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{ "name"=>"unit-test-123-iphone rdc one", "testOptions"=>{ "class"=>%w[com.some.package.testing.SomeClassOne com.some.package.testing.SomeClassTwo com.some.package.testing.SomeClassThree com.some.package.testing.SomeClassFour], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{ "name"=>"iPhone RDC One", "orientation"=>"portrait", "platformVersions"=>["11.0"]}]}, { "name"=>"unit-test-123-iphone rdc two", "testOptions"=>{ "class"=>%w[com.some.package.testing.SomeClassOne com.some.package.testing.SomeClassTwo com.some.package.testing.SomeClassThree com.some.package.testing.SomeClassFour], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{ "name"=>"iPhone RDC Two", "orientation"=>"portrait", "platformVersions"=>["11.0"]}]}]}
      expect(config).to eql expected_config
    end

    it 'should allow ios users to specify an array of classes to execute on rdc' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app: '#{File.expand_path("my-demo-app-ios")}/myTestApp.app',
                         test_app: '#{File.expand_path("my-demo-app-ios")}/myTestRunner.app',
                         region: 'eu',
                         devices: [ {name: 'iPhone RDC One'}],
                         test_class: ['MyDemoAppUITests.SomeClassOne', 'MyDemoAppUITests.SomeClassTwo', 'MyDemoAppUITests.SomeClassThree', 'MyDemoAppUITests.SomeClassFour']
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/myTestApp.app"), "testApp"=> File.expand_path("my-demo-app-ios/myTestRunner.app")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{ "name"=>"unit-test-123-iphone rdc one", "testOptions"=>{"class"=>%w[MyDemoAppUITests.SomeClassOne MyDemoAppUITests.SomeClassTwo MyDemoAppUITests.SomeClassThree MyDemoAppUITests.SomeClassFour]}, "devices"=>[{ "name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}]}
      expect(config).to eql expected_config
    end

    it 'should raise an error when user specifies virtual device option for ios platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                         test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                         region: 'eu',
                         test_target: 'MyDemoAppUITests',
                         emulators: [ {name: 'iPhone Simulator', orientation: 'portrait', platform_versions: %w[13.1]}],
                         test_distribution: 'shard',
          })
        end").runner.execute(:test)
      end.to raise_error("❌ Sauce Labs platform does not currently support virtual device execution for ios apps")
    end
  end
end
