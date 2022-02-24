require_relative 'spec_helper'
require_relative '../lib/fastlane/plugin/rsaucectl/helper/config'

describe Fastlane::Saucectl::ConfigGenerator do
  describe 'config generator' do
    before do
      @config = {}
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
    end

    after do
      FileUtils.rm_rf('.sauce')
    end

    it 'should handle us region' do
      @config[:region] = 'us'
      expect(Fastlane::Saucectl::ConfigGenerator.new(@config).set_region).to eql 'us-west-1'
    end

    it 'should handle us region when not set' do
      expect(Fastlane::Saucectl::ConfigGenerator.new(@config).set_region).to eql 'us-west-1'
    end

    it 'should handle eu region' do
      @config[:region] = 'eu'
      expect(Fastlane::Saucectl::ConfigGenerator.new(@config).set_region).to eql 'eu-central-1'
    end

    it 'should create config.yml file based on user specified virtual device configurations' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:clear_data] = true
      @config[:use_test_orchestrator] = true
      @config[:app_path] = File.expand_path("my-demo-app-android")
      @config[:app_name] = 'myTestApp.apk'
      @config[:test_runner_app] = 'myTestRunner.apk'
      @config[:emulators] = [
        {
          name: "Android GoogleApi Emulator",
          platform_versions: %w[10.0 11.0],
          orientation: 'portrait'
        }
      ]
      File.open('config.yml', 'w') { |f| YAML.dump(@config, f) }

      Fastlane::Saucectl::ConfigGenerator.new(@config).create

      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")
      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>nil, "sauce"=>{"region"=>"us-west-1", "concurrency"=>nil, "metadata"=>{"name"=>"-", "build"=>"Release "}}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"espresso-logintest#nocredentiallogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>["10.0", "11.0"]}]}, {"name"=>"espresso-logintest#nousernamelogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{"name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=> %w[10.0 11.0] }]}, { "name"=>"espresso-logintest#nopasswordlogintest", "testOptions"=>{ "class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{ "name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>["10.0", "11.0"]}]}, { "name"=>"espresso-logintest#succesfullogintest", "testOptions"=>{ "class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{ "name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=> %w[10.0 11.0] }]}, { "name"=>"espresso-webviewtest#withouturltest", "testOptions"=>{ "class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{ "name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=>["10.0", "11.0"]}]}, { "name"=>"espresso-webviewtest#webviewtest", "testOptions"=>{ "class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "emulators"=>[{ "name"=>"Android GoogleApi Emulator", "orientation"=>"portrait", "platformVersions"=> %w[10.0 11.0] }]}]}
      expect(expected_config).to eql config
    end

    it 'should create config.yml file based on user specified android real device configurations' do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:platform] = 'android'
      @config[:kind] = 'espresso'
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:clear_data] = true
      @config[:use_test_orchestrator] = true
      @config[:app_path] = File.expand_path("my-demo-app-android")
      @config[:app_name] = 'myTestApp.apk'
      @config[:test_runner_app] = 'myTestRunner.apk'
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

      File.open('config.yml', 'w') { |f| YAML.dump(@config, f) }

      Fastlane::Saucectl::ConfigGenerator.new(@config).create

      config_folder = File.expand_path("../", "#{__dir__}")
      config = YAML.load_file("#{config_folder}/.sauce/config.yml")

      expected_config = {"apiVersion"=>"v1alpha", "kind"=>"espresso", "retries"=>nil, "sauce"=>{"region"=>"us-west-1", "concurrency"=>nil, "metadata"=>{"name"=>"-", "build"=>"Release "}}, "espresso"=>{"app"=> File.expand_path("my-demo-app-android/myTestApp.apk"), "testApp"=> File.expand_path("my-demo-app-android/myTestRunner.apk")}, "artifacts"=>{"download"=>{"when"=>"always", "match"=>["junit.xml"], "directory"=>"./artifacts/"}}, "reporters"=>{"junit"=>{"enabled"=>true}}, "suites"=>[{"name"=>"espresso-logintest#nocredentiallogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"Some Android Device", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>nil}}]}, {"name"=>"espresso-logintest#nousernamelogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"Some Android Device", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}, {"name"=>"espresso-logintest#nopasswordlogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"Some Android Device", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}, {"name"=>"espresso-logintest#succesfullogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"Some Android Device", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}, {"name"=>"espresso-webviewtest#withouturltest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"Some Android Device", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}, {"name"=>"espresso-webviewtest#webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"name"=>"Some Android Device", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}, {"name"=>"espresso-logintest#nocredentiallogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"android_googleApi_Emulator", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>"PHONE", "private"=>nil}}]}, {"name"=>"espresso-logintest#nousernamelogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"android_googleApi_Emulator", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}, {"name"=>"espresso-logintest#nopasswordlogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"android_googleApi_Emulator", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}, {"name"=>"espresso-logintest#succesfullogintest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"android_googleApi_Emulator", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}, {"name"=>"espresso-webviewtest#withouturltest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"android_googleApi_Emulator", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}, {"name"=>"espresso-webviewtest#webviewtest", "testOptions"=>{"class"=>"com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest", "clearPackageData"=>true, "useTestOrchestrator"=>true}, "devices"=>[{"id"=>"android_googleApi_Emulator", "orientation"=>"portrait", "options"=>{"carrierConnectivity"=>false, "deviceType"=>nil, "private"=>nil}}]}]}
      expect(expected_config).to eql config
    end
  end
end
