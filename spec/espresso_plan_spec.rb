require_relative "spec_helper"
require_relative "../lib/fastlane/plugin/rsaucectl/helper/espresso"

describe Fastlane::Saucectl::Espresso do
  describe "espresso test plan" do
    before do
      @config = {}
      @config[:username] = "foo"
      @config[:access_key] = "123"
    end

    it "should return package, class and test case array" do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      test_plan = Fastlane::Saucectl::Espresso.new(@config)
      test_class = test_plan.test_data.first
      expect(test_class[:package]).to eql("com.saucelabs.mydemoapp.android.view.activities")
      expect(test_class[:class]).to eql("LoginTest")
      expect(test_class[:tests]).to eql(%w[noCredentialLoginTest noUsernameLoginTest noPasswordLoginTest succesfulLoginTest])
    end

    it "should fetch tests by package in executable format" do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:test_distribution] = "package"
      test_plan = Fastlane::Saucectl::Espresso.new(@config)
      test_packages = test_plan.test_distribution
      expect(test_packages).to eql(["com.saucelabs.mydemoapp.android.view.activities"])
    end

    it "should fetch tests by test class in executable format" do
      expected_classes = %w[com.saucelabs.mydemoapp.android.view.activities.LoginTest
                            com.saucelabs.mydemoapp.android.view.activities.WebViewTest]
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:test_distribution] = "class"
      test_plan = Fastlane::Saucectl::Espresso.new(@config)
      test_class = test_plan.test_distribution
      expect(test_class).to eql(expected_classes)
    end

    it "should fetch tests by test case in executable format" do
      expected_test_cases = %w[com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest
                               com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest
                               com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest
                               com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest
                               com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest
                               com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest]
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:test_distribution] = "testCase"
      test_plan = Fastlane::Saucectl::Espresso.new(@config)
      test_cases = test_plan.test_distribution
      expect(test_cases).to eql(expected_test_cases)
    end

    it "should fetch tests by test case in executable format when sharding" do
      expected_test_cases = %w[com.saucelabs.mydemoapp.android.view.activities.LoginTest#noCredentialLoginTest
                               com.saucelabs.mydemoapp.android.view.activities.LoginTest#noUsernameLoginTest
                               com.saucelabs.mydemoapp.android.view.activities.LoginTest#noPasswordLoginTest
                               com.saucelabs.mydemoapp.android.view.activities.LoginTest#succesfulLoginTest
                               com.saucelabs.mydemoapp.android.view.activities.WebViewTest#withoutUrlTest
                               com.saucelabs.mydemoapp.android.view.activities.WebViewTest#webViewTest]
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:test_distribution] = "shard"
      test_plan = Fastlane::Saucectl::Espresso.new(@config)
      test_cases = test_plan.test_distribution
      expect(test_cases).to eql(expected_test_cases)
    end

    it "should raise an error when unrecognised test distribution type is specified" do
      invalid_distribution_method = "fail"
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      @config[:test_distribution] = invalid_distribution_method
      expect { Fastlane::Saucectl::Espresso.new(@config).test_distribution }
        .to raise_error(StandardError, "#{invalid_distribution_method} is not a valid method of test distribution")
    end

    it "should strip ignored tests" do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      test_plan = Fastlane::Saucectl::Espresso.new(@config)
      test_plan.test_data.each do |spec|
        expect(spec[:tests].include?("dashboardProductTest")).to be_falsey
      end
    end

    it "should get ignored tests" do
      @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
      test_plan = Fastlane::Saucectl::Espresso.new(@config)
      ignored_tests = test_plan.fetch_disabled_tests(@config[:path_to_tests])
      expect(ignored_tests.include?("dashboardProductTest")).to be_truthy
    end
  end
end
