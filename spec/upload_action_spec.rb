require_relative "spec_helper"
require_relative '../spec/utils/mock_api'

describe Fastlane::Actions::UploadAction do
  describe "sauce labs upload action" do

    let(:action) { Fastlane::Actions::UploadAction }

    before do
      mock_api = Saucectl::MockApi.new
      mock_api.with(:post,
                    'storage/upload',
                    upload_header,
                    'apps_response.json',
                    200)
    end

    it "should return application id when successfully uploaded to sauce" do

      action.run({
                   platform: 'android',
                   sauce_username: 'foo',
                   sauce_access_key: 'bar123',
                   app_name: 'Android.MyCustomApp.apk',
                   app_path: 'app/build/outputs/apk/debug/app-debug.apk',
                   region: 'eu'
                 })

      expect(ENV['SAUCE_APP_ID']).to eql('1234-1234-1234-1234-1234')
    end

    it "should raise an error when no platform is specified" do
      expect do
        action.run({
                     platform: '',
                     sauce_username: '',
                     sauce_access_key: '',
                     app_name: 'Android.MyCustomApp.apk',
                     app_path: 'app/build/outputs/apk/debug/app-debug.apk',
                     region: 'eu'
                   })

      end.to raise_error("No platform specified, set using: platform: 'android'")
    end

    it "should raise an error when no application path is specified" do
      expect do
        action.run({
                     platform: 'android',
                     sauce_username: 'foo',
                     sauce_access_key: 'bar',
                     app_name: 'Android.MyCustomApp.apk',
                     app_path: '',
                     region: 'eu'
                   })

      end.to raise_error("No App path given, set using: app_path: 'path/to/my/testApp.apk'")
    end

    it "should raise an error when no app_name is specified" do
      expect do
        action.run({
                     platform: 'android',
                     sauce_username: 'foo',
                     sauce_access_key: 'bar',
                     app_name: '',
                     app_path: 'app/build/outputs/apk/debug/app-debug.apk',
                     region: 'eu'
                   })

      end.to raise_error("No App name given, set using: app_name: 'testApp.apk'")
    end

    it "should raise an error when invalid region is specified" do
      expect do
        action.run({
                     platform: 'android',
                     sauce_username: 'foo',
                     sauce_access_key: 'bar',
                     app_name: 'Android.MyCustomApp.apk',
                     app_path: 'app/build/outputs/apk/debug/app-debug.apk',
                     region: 'foobar'
                   })

      end.to raise_error("foobar is an invalid region. Supported regions are 'us' and 'eu'")
    end

    it "should raise an error when no sauce username is specified" do
      expect do
        action.run({
                     platform: 'android',
                     sauce_username: '',
                     sauce_access_key: 'bar',
                     app_name: 'Android.MyCustomApp.apk',
                     app_path: 'app/build/outputs/apk/debug/app-debug.apk',
                     region: 'eu'
                   })

      end.to raise_error("No sauce labs username provided, set using: sauce_username: 'sauce user name', or consider setting your credentials as environment variables.")
    end

    it "should raise an error when no sauce access key is specified" do
      expect do
        action.run({
                     platform: 'android',
                     sauce_username: 'foo',
                     sauce_access_key: '',
                     app_name: 'Android.MyCustomApp.apk',
                     app_path: 'app/build/outputs/apk/debug/app-debug.apk',
                     region: 'eu'
                   })

      end.to raise_error("No sauce labs access key provided, set using: sauce_access_key: '1234' or consider setting your credentials as environment variables.")
    end
  end
end
