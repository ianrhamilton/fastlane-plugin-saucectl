require_relative "spec_helper"
require_relative '../spec/utils/mock_api'

describe Fastlane::Actions::SauceAppsAction do
  before do
    @config = {}
  end

  it "should return application list of applications for platform by platform" do
    mock_api = Saucectl::MockApi.new
    mock_api.with(:get,
                  'storage/files?kind=android&q=test.apk',
                  default_header,
                  'apps_response.json',
                  200)

    response = Fastlane::FastFile.new.parse("lane :test do
          sauce_apps({
                    platform: 'android',
                    query: 'test.apk',
                    region: 'eu',
                    sauce_username: 'foo',
                    sauce_access_key: 'bar123',
                  })
        end").runner.execute(:test)
    expect(response.code).to eql('200')
  end
end
