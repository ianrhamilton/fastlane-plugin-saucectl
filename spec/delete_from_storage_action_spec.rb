require_relative "spec_helper"
require_relative '../spec/utils/mock_api'

describe Fastlane::Actions::DeleteFromStorageAction do
  describe 'Delete apps from Sauce Labs Storage' do
    it "should delete app by user specified app id" do
      mock_api = Saucectl::MockApi.new
      mock_api.with(:delete,
                    'storage/files/1235-1235-1235-1235-1235',
                    delete_header,
                    'delete_by_id_response.json',
                    200)

      response = Fastlane::FastFile.new.parse("lane :test do
          delete_from_storage({
                    region: 'eu',
                    platform: 'android',
                    app_name: 'Android.MyCustomApp.apk',
                    sauce_username: 'foo',
                    sauce_access_key: 'bar123',
                    app_id: '1235-1235-1235-1235-1235'
                  })
        end").runner.execute(:test)
      expect(response.code).to eql('200')
    end

    it "should delete app by user specified group id" do
      mock_api = Saucectl::MockApi.new
      mock_api.with(:delete,
                    "storage/files/123456789",
                    delete_header,
                    'delete_response.json',
                    200)

      response = Fastlane::FastFile.new.parse("lane :test do
          delete_from_storage({
                    region: 'eu',
                    platform: 'android',
                    app_name: 'Android.MyCustomApp.apk',
                    sauce_username: 'foo',
                    sauce_access_key: 'bar123',
                    group_id: '123456789'
                  })
        end").runner.execute(:test)
      expect(response.code).to eql('200')
    end
  end
end
