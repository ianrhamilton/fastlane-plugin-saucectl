require_relative "spec_helper"

describe Fastlane::Saucectl::XCTest do
  before do
    @config = {}
  end

  it "should read user all tests from ios xctest projects, excluding any skipped tests" do
    @config[:test_target] = "MyDemoAppUITests"
    test_array = %w[testNavigateToCart testNavigateToMore testNavigateMoreToWebview testNavigateMoreToAbout testNavigateMoreToQRCode testNavigateMoreToGeoLocation testNavigateMoreToDrawing testNavigateFromCartToCatalog testNavigateCartToCatalog]
    test_plan = Fastlane::Saucectl::XCTest.new(@config).test_data.first
    expect(test_plan[:class]).to eq("NavigationTest")
    expect(test_plan[:tests]).to eq test_array
  end

  it "should fetch tests by test class" do
    expected_classes = %w[MyDemoAppUITests.NavigationTest MyDemoAppUITests.ProductDetailsTest MyDemoAppUITests.ProductListingPageTest]
    @config[:test_target] = "MyDemoAppUITests"
    @config[:test_distribution] = "class"
    test_plan = Fastlane::Saucectl::XCTest.new(@config)
    test_class = test_plan.test_distribution
    expect(test_class).to eql(expected_classes)
  end

  it "should fetch tests by test case in executable format" do
    test_array = %w[MyDemoAppUITests.NavigationTest/testNavigateToCart MyDemoAppUITests.NavigationTest/testNavigateToMore MyDemoAppUITests.NavigationTest/testNavigateMoreToWebview MyDemoAppUITests.NavigationTest/testNavigateMoreToAbout MyDemoAppUITests.NavigationTest/testNavigateMoreToQRCode MyDemoAppUITests.NavigationTest/testNavigateMoreToGeoLocation MyDemoAppUITests.NavigationTest/testNavigateMoreToDrawing MyDemoAppUITests.NavigationTest/testNavigateFromCartToCatalog MyDemoAppUITests.NavigationTest/testNavigateCartToCatalog MyDemoAppUITests.ProductDetailsTest/testProductDetails MyDemoAppUITests.ProductDetailsTest/testProductDetailsPrice MyDemoAppUITests.ProductDetailsTest/testProductDetailsHighlights MyDemoAppUITests.ProductDetailsTest/testProductDetailsDecreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsIncreaseNumberOfItems MyDemoAppUITests.ProductDetailsTest/testProductDetailsDefaultColor MyDemoAppUITests.ProductDetailsTest/testProductDetailsColorsSwitch MyDemoAppUITests.ProductDetailsTest/testProductDetailsRatesSelection MyDemoAppUITests.ProductDetailsTest/testProductDetailsAddToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddItemToCart MyDemoAppUITests.ProductListingPageTest/testProductListingPageAddMultipleItemsToCart]
    @config[:test_target] = "MyDemoAppUITests"
    @config[:test_distribution] = "testCase"
    test_plan = Fastlane::Saucectl::XCTest.new(@config)
    test_cases = test_plan.test_distribution
    expect(test_cases).to eql(test_array)
  end

  it "should fetch tests by test class when sharding" do
    test_array = %w[MyDemoAppUITests.NavigationTest MyDemoAppUITests.ProductDetailsTest MyDemoAppUITests.ProductListingPageTest]
    @config[:test_target] = "MyDemoAppUITests"
    @config[:test_distribution] = "shard"
    test_plan = Fastlane::Saucectl::XCTest.new(@config)
    test_cases = test_plan.test_distribution
    expect(test_cases).to eql(test_array)
  end

  it "should raise an error when unrecognised test distribution type is specified" do
    invalid_distribution_method = "fail"
    @config[:test_target] = "MyDemoAppUITests"
    @config[:test_distribution] = invalid_distribution_method
    distribution_types = %w[class testCase shard]
    expect { Fastlane::Saucectl::XCTest.new(@config).test_distribution }
      .to raise_error(StandardError, "#{@config[:test_distribution]} is not a valid method of test distribution. \n Supported types for iOS: \n #{distribution_types}")
  end

  it "should raise an error when user specifies invalid test plan" do
    @config[:test_plan] = "UITest"
    expect { Fastlane::Saucectl::XCTest.new(@config).valid_test_plan? }
      .to raise_error(StandardError, "#{@config[:test_plan]} was not found in workspace")
  end

  it "should strip skipped tests when user specifies test plan containing stripped tests" do
    @config[:test_plan] = "UITests"
    test_plan = Fastlane::Saucectl::XCTest.new(@config)
    test_plan.test_data.each do |spec|
      expect(spec).not_to include("testNavigateCartToCatalog")
      expect(spec).not_to include("testOne")
      expect(spec).not_to include("testTwo")
      expect(spec).not_to include("testThree")
    end
  end

  it "should get enabled tests from test plan" do
    enabled_tests = [{ :class => "SomeSpec", :tests => ["testOne"] },
                     { :class => "SomeSpec", :tests => ["testTwo"] },
                     { :class => "SomeSpec", :tests => ["testThree"] },
                     { :class => "SomeSpec", :tests => ["testFour"] },
                     { :class => "SomeSpec", :tests => ["testFive"] }]
    @config[:test_plan] = "EnabledUITests"
    test_plan = Fastlane::Saucectl::XCTest.new(@config).test_data
    expect(test_plan).to eql(enabled_tests)
  end

  it "should get skipped tests from test plan" do
    @config[:test_plan] = "UITests"
    test_plan = Fastlane::Saucectl::XCTest.new(@config).fetch_disabled_tests
    expect(test_plan).to eql([{ :class => "My_Demo_AppUITests", :tests => "testNavigateCartToCatalog" }, { :class => "My_Demo_OtherTests", :tests => "testOne" }, { :class => "My_Demo_OtherTests", :tests => "testTwo" }, { :class => "My_Demo_OtherTests", :tests => "testThree" }])
  end

  it "should get a mixture of test classes and test cases from test plans" do
    @config[:test_plan] = "MixedUITests"
    test_plan = Fastlane::Saucectl::XCTest.new(@config).scan_test_class('NavigationTest')
    expect(test_plan).to eql([{:class=>"NavigationTest", :tests=> %w[testNavigateToCart testNavigateToMore testNavigateMoreToWebview testNavigateMoreToAbout testNavigateMoreToQRCode testNavigateMoreToGeoLocation testNavigateMoreToDrawing testNavigateFromCartToCatalog testNavigateCartToCatalog] }])
  end
end
