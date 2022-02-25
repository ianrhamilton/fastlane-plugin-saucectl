require_relative "spec_helper"

describe Fastlane::Saucectl::XCTest do
  before do
    @config = {}
  end

  it "should read user all tests from ios xctest projects, excluding any skipped tests" do
    @config[:test_target] = "MyDemoAppUITests"
    test_array = %w[testProductListingPageAddItemToCart testProductListingPageAddMultipleItemsToCart
                      testProductListingPageDefault testProductDetails testProductDetailsPrice testProductDetailsHighlights
                      testProductDetailsDecreaseNumberOfItems testProductDetailsIncreaseNumberOfItems testProductDetailsDefaultColor
                      testProductDetailsColorsSwitch testProductDetailsRatesSelection testProductDetailsAddToCart
                      testProductDetailsProceedToCheckout testNavigateToCart testNavigateToMore testNavigateMoreToWebview
                      testNavigateMoreToAbout testNavigateMoreToQRCode testNavigateMoreToGeoLocation
                      testNavigateMoreToDrawing testNavigateFromCartToCatalog testNavigateCartToCatalog]
    test_plan = Fastlane::Saucectl::XCTest.new(@config).test_data.first

    expect(test_plan[:class]).to eq("My_Demo_AppUITests")
    expect(test_plan[:tests]).to eq test_array
  end

  it "should fetch tests by test class" do
    expected_classes = %w[MyDemoAppUITests.My_Demo_AppUITests MyDemoAppUITests.My_Demo_OtherTests]
    @config[:test_target] = "MyDemoAppUITests"
    @config[:test_distribution] = "class"
    test_plan = Fastlane::Saucectl::XCTest.new(@config)
    test_class = test_plan.test_distribution
    expect(test_class).to eql(expected_classes)
  end

  it "should fetch tests by test case in executable format" do
    test_array = %w[MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart
                      MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart
                      MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetails
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateCartToCatalog
                      MyDemoAppUITests.My_Demo_OtherTests/testOne
                      MyDemoAppUITests.My_Demo_OtherTests/testTwo
                      MyDemoAppUITests.My_Demo_OtherTests/testThree
                      MyDemoAppUITests.My_Demo_OtherTests/testFour
                      MyDemoAppUITests.My_Demo_OtherTests/testFive]
    @config[:test_target] = "MyDemoAppUITests"
    @config[:test_distribution] = "testCase"
    test_plan = Fastlane::Saucectl::XCTest.new(@config)
    test_cases = test_plan.test_distribution

    expect(test_cases).to eql(test_array)
  end

  it "should fetch tests by test case when sharding" do
    test_array = %w[MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddItemToCart
                      MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageAddMultipleItemsToCart
                      MyDemoAppUITests.My_Demo_AppUITests/testProductListingPageDefault
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetails
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsPrice
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsHighlights
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDecreaseNumberOfItems
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsIncreaseNumberOfItems
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsDefaultColor
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsColorsSwitch
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsRatesSelection
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsAddToCart
                      MyDemoAppUITests.My_Demo_AppUITests/testProductDetailsProceedToCheckout
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateToCart
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateToMore
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToWebview
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToAbout
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToQRCode
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToGeoLocation
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateMoreToDrawing
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateFromCartToCatalog
                      MyDemoAppUITests.My_Demo_AppUITests/testNavigateCartToCatalog
                      MyDemoAppUITests.My_Demo_OtherTests/testOne
                      MyDemoAppUITests.My_Demo_OtherTests/testTwo
                      MyDemoAppUITests.My_Demo_OtherTests/testThree
                      MyDemoAppUITests.My_Demo_OtherTests/testFour
                      MyDemoAppUITests.My_Demo_OtherTests/testFive]
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
    enabled_tests = [{ :class => "SomeSpec", :tests => "MyDemoAppUITests.SomeSpec/testOne" },
                     { :class => "SomeSpec", :tests => "MyDemoAppUITests.SomeSpec/testTwo" },
                     { :class => "SomeSpec", :tests => "MyDemoAppUITests.SomeSpec/testThree" },
                     { :class => "SomeSpec", :tests => "MyDemoAppUITests.SomeSpec/testFour" },
                     { :class => "SomeSpec", :tests => "MyDemoAppUITests.SomeSpec/testFive" }]
    @config[:test_plan] = "EnabledUITests"
    test_plan = Fastlane::Saucectl::XCTest.new(@config).test_data
    expect(test_plan).to eql(enabled_tests)
  end

  it "should get skipped tests from test plan" do
    @config[:test_plan] = "UITests"
    test_plan = Fastlane::Saucectl::XCTest.new(@config).fetch_disabled_tests
    expect(test_plan).to eql([{ :class => "My_Demo_AppUITests", :tests => "testNavigateCartToCatalog" }, { :class => "My_Demo_OtherTests", :tests => "testOne" }, { :class => "My_Demo_OtherTests", :tests => "testTwo" }, { :class => "My_Demo_OtherTests", :tests => "testThree" }])
  end
end
