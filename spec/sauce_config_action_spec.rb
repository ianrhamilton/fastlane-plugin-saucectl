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
          sauce_config({ platform: 'android',
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

    it 'should create config.yml file for android espresso based on user specified virtual device configurations' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                         test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: %w[10.0 11.0], orientation: 'portrait'}]
      })
    end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      p config
      expected_config = { "apiVersion" => "v1alpha", "kind" => "espresso", "retries" => 0, "sauce" => { "region" => "eu-central-1", "concurrency" => 1, "metadata" => { "name" => "unit-test-123", "build" => "Release " } }, "espresso" => { "app" => File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp" => File.expand_path("my-demo-app-android/myTestRunner.apk") }, "artifacts" => { "download" => { "when" => "always", "match" => ["junit.xml"], "directory" => "./artifacts/" } }, "reporters" => { "junit" => { "enabled" => true } }, "suites" => [{ "name" => "unit-test-123-logintest", "testOptions" => { "class" => "com.saucelabs.mydemoapp.android.view.activities.LoginTest", "clearPackageData" => true, "useTestOrchestrator" => true }, "emulators" => [{ "name" => "Android GoogleApi Emulator", "orientation" => "portrait", "platformVersions" => ["10.0", "11.0"] }] }, { "name" => "unit-test-123-webviewtest", "testOptions" => { "class" => "com.saucelabs.mydemoapp.android.view.activities.WebViewTest", "clearPackageData" => true, "useTestOrchestrator" => true }, "emulators" => [{ "name" => "Android GoogleApi Emulator", "orientation" => "portrait", "platformVersions" => ["10.0", "11.0"] }] }] }
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
      expected_config = { "apiVersion" => "v1alpha", "kind" => "espresso", "retries" => 0, "sauce" => { "region" => "eu-central-1", "concurrency" => 1, "metadata" => { "name" => "unit-test-123", "build" => "Release " } }, "espresso" => { "app" => File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp" => File.expand_path("my-demo-app-android/myTestRunner.apk") }, "artifacts" => { "download" => { "when" => "always", "match" => ["junit.xml"], "directory" => "./artifacts/" } }, "reporters" => { "junit" => { "enabled" => true } }, "suites" => [{ "name" => "unit-test-123-logintest#nocredentiallogintest", "testOptions" => { "class" => "com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "clearPackageData" => true, "useTestOrchestrator" => true }, "devices" => [{ "name" => "RDC One", "orientation" => "portrait", "options" => { "carrierConnectivity" => false, "deviceType" => "PHONE", "private" => true }, "platformVersion" => "11.0" }] }, { "name" => "unit-test-123-logintest#nousernamelogintest", "testOptions" => { "class" => "com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "clearPackageData" => true, "useTestOrchestrator" => true }, "devices" => [{ "name" => "RDC One", "orientation" => "portrait", "options" => { "carrierConnectivity" => false, "deviceType" => nil, "private" => true }, "platformVersion" => "11.0" }] }, { "name" => "unit-test-123-logintest#nopasswordlogintest", "testOptions" => { "class" => "com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "clearPackageData" => true, "useTestOrchestrator" => true }, "devices" => [{ "name" => "RDC One", "orientation" => "portrait", "options" => { "carrierConnectivity" => false, "deviceType" => nil, "private" => true }, "platformVersion" => "11.0" }] }, { "name" => "unit-test-123-logintest#succesfullogintest", "testOptions" => { "class" => "com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "clearPackageData" => true, "useTestOrchestrator" => true }, "devices" => [{ "name" => "RDC One", "orientation" => "portrait", "options" => { "carrierConnectivity" => false, "deviceType" => nil, "private" => true }, "platformVersion" => "11.0" }] }, { "name" => "unit-test-123-webviewtest#withouturltest", "testOptions" => { "class" => "com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "clearPackageData" => true, "useTestOrchestrator" => true }, "devices" => [{ "name" => "RDC One", "orientation" => "portrait", "options" => { "carrierConnectivity" => false, "deviceType" => nil, "private" => true }, "platformVersion" => "11.0" }] }, { "name" => "unit-test-123-webviewtest#webviewtest", "testOptions" => { "class" => "com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest", "clearPackageData" => true, "useTestOrchestrator" => true }, "devices" => [{ "name" => "RDC One", "orientation" => "portrait", "options" => { "carrierConnectivity" => false, "deviceType" => nil, "private" => true }, "platformVersion" => "11.0" }] }] }
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
                         devices: [ {name: 'RDC One', orientation: 'portrait', platform_version: '11.0'}]
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-shard 1", "testOptions"=>{"class"=>["com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest"], "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}, "platformVersion"=>"11.0"}]}]}
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

    it 'should raise an error when user does not specify a testPlan or testTarget for ios platform' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'ios',
                         kind: 'xcuitest',
                         app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                         test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                         region: 'eu',
                         test_distribution: 'shard',
                         devices: [ {name: 'iPhone RDC One'}]
          })
        end").runner.execute(:test)
      end.to raise_error('❌ For ios you must specify test_target or test_plan')
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
                         test_target: 'MyDemoAppUITests'
          })
        end").runner.execute(:test)
      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")

      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=>  File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=>  File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-navigationtest", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productlistingpagetest", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productlistingpagetest", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}]}
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{ "name"=>"unit-test-123-shard 1", "testOptions"=>{"class"=> %w[MyDemoAppUITests.NavigationTest/testNavigateToCart MyDemoAppUITests.NavigationTest/testNavigateToMore MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog MyDemoAppUITests.NavigationTest/testNavigateCartToCatalog MyDemoAppUITests.ProductDetailsTest/testProductDetails] }, "devices"=>[{ "name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, { "name"=>"unit-test-123-shard 2", "testOptions"=>{ "class"=> %w[MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart] }, "devices"=>[{ "id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}]}
      p expected_config
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"unit-test-123-navigationtest/testnavigatetocart", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateToCart"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatetomore", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateToMore"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretowebview", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretoabout", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretoqrcode", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretogeolocation", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretodrawing", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatefromcarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatecarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateCartToCatalog"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetails", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetails"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsprice", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailshighlights", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsdecreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsincreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsdefaultcolor", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailscolorsswitch", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsratesselection", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsaddtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productlistingpagetest/testproductlistingpageadditemtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productlistingpagetest/testproductlistingpageaddmultipleitemstocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart"}, "devices"=>[{"name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatetocart", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateToCart"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatetomore", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateToMore"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretowebview", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretoabout", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretoqrcode", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretogeolocation", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatemoretodrawing", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatefromcarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-navigationtest/testnavigatecarttocatalog", "testOptions"=>{"class"=>"MyDemoAppUITests.NavigationTest/testNavigateCartToCatalog"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetails", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetails"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsprice", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailshighlights", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsdecreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsincreasenumberofitems", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsdefaultcolor", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailscolorsswitch", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsratesselection", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productdetailstest/testproductdetailsaddtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productlistingpagetest/testproductlistingpageadditemtocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}, {"name"=>"unit-test-123-productlistingpagetest/testproductlistingpageaddmultipleitemstocart", "testOptions"=>{"class"=>"MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart"}, "devices"=>[{"id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>true}}]}]}
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
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=>  File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{ "name"=>"unit-test-123-shard 1", "testOptions"=>{"class"=> %w[MyDemoAppUITests.SomeSpec/testOne MyDemoAppUITests.SomeSpec/testTwo MyDemoAppUITests.SomeSpec/testThree] }, "devices"=>[{ "name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, { "name"=>"unit-test-123-shard 2", "testOptions"=>{ "class"=> %w[MyDemoAppUITests.SomeSpec/testFour MyDemoAppUITests.SomeSpec/testFive] }, "devices"=>[{ "id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}]}
      expect(config).to eql expected_config
    end

    it 'should create real device config.yml file based on xcode test plan using testCase distribution method' do
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
      expected_config =  {"apiVersion"=>"v1alpha", "kind"=>"xcuitest", "retries"=>0, "sauce"=>{"region"=>"eu-central-1", "concurrency"=>1, "metadata"=>{"name"=>"unit-test-123", "build"=>"Release "}}, "xcuitest"=>{"app"=> File.expand_path("my-demo-app-ios/MyTestApp.ipa"), "testApp"=> File.expand_path("my-demo-app-ios/MyTestAppRunner.ipa")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{ "name"=>"unit-test-123-uitests", "testOptions"=>{"class"=> %w[MyDemoAppUITests.NavigationTest/testNavigateToCart MyDemoAppUITests.NavigationTest/testNavigateToMore MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog MyDemoAppUITests.ProductDetailsTest/testProductDetails MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart] }, "devices"=>[{ "name"=>"iPhone RDC One", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}, { "name"=>"unit-test-123-uitests", "testOptions"=>{ "class"=> %w[MyDemoAppUITests.NavigationTest/testNavigateToCart MyDemoAppUITests.NavigationTest/testNavigateToMore MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog MyDemoAppUITests.ProductDetailsTest/testProductDetails MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart] }, "devices"=>[{ "id"=>"iphone_rdc_two", "orientation"=>"portrait", "options"=>{ "carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>true}}]}]}
      expect(config).to eql expected_config
    end

    it 'should raise an error when user specifies virtual device option' do
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
