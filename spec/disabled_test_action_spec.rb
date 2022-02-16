require_relative "spec_helper"
require_relative '../spec/utils/mock_api'

describe Fastlane::Actions::DisabledTestsAction do

  it "espresso tests should return an array of disabled test cases" do
    response = Fastlane::FastFile.new.parse("lane :test do
          disabled_tests({platform: 'android',
                         path_to_tests: 'my-demo-app-android/app/src/androidTest'
          })
        end").runner.execute(:test)
    expect(response).to include('dashboardProductTest')
  end

  it "xctest tests should return an array of disabled test cases by test plan" do
    response = Fastlane::FastFile.new.parse("lane :test do
          disabled_tests({platform: 'ios',
                         test_plan: 'UITests'
          })
        end").runner.execute(:test)
    expect(response).to include("My_Demo_AppUITests/testNavigateCartToCatalog")
  end

  it "xctest tests should return an array of disabled test cases by test target" do
    response = Fastlane::FastFile.new.parse("lane :test do
          disabled_tests({platform: 'ios',
                         test_plan: 'UITests'
          })
        end").runner.execute(:test)
    expect(response).to include("My_Demo_AppUITests/testNavigateCartToCatalog")
  end

  it "ios platform should raise an error when user does not specify test plan or test target" do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
          disabled_tests({platform: 'ios'})
        end").runner.execute(:test)
      end.to raise_error('Cannot get tests for an ios project without a known test plan or test target')
  end

  it "android platform should raise an error when user specifies test_target" do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
          disabled_tests({platform: 'android',
                          test_target: 'someTarget'})
        end").runner.execute(:test)
    end.to raise_error('test_plan and test_target options are reserved for ios projects only')
  end

  it "android platform should raise an error when user specifies test_plan" do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
          disabled_tests({platform: 'android',
                          test_plan: 'somePlan'})
        end").runner.execute(:test)
    end.to raise_error('test_plan and test_target options are reserved for ios projects only')
  end
end
