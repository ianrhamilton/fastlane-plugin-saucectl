require_relative "spec_helper"
require_relative '../spec/utils/mock_api'

describe Fastlane::Actions::SauceUploadAction do
  describe 'Upload to Sauce Labs Storage' do

    before do
      mock_api = Saucectl::MockApi.new
      mock_api.with(:post,
                    'storage/upload',
                    upload_header,
                    'upload_response.json',
                    201)
      @file = "#{__dir__}/utils/mocks/app-debug.apk"
    end

    it "should return application id when successfully uploaded to sauce" do
      upload_id = Fastlane::FastFile.new.parse("lane :test do
          sauce_upload({platform: 'android',
                        sauce_username: 'foo',
                        sauce_access_key: 'bar123',
                        app: 'Android.MyCustomApp.apk',
                        file: '#{@file}',
                        region: 'eu'
             })
        end").runner.execute(:test)
      expect(upload_id).to eql('1234-1234-1234-1234-1234')
    end

    it "should raise an error when no platform is specified" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_upload({
                    platform: '',
                    sauce_username: 'foo',
                    sauce_access_key: 'bar123',
                    app: 'Android.MyCustomApp.apk',
                    file: '#{@file}',
                    region: 'eu'
                  })
        end").runner.execute(:test)
      end.to raise_error("No platform specified, set using: platform: 'android'")
    end

    it "should raise an error when no application path is specified" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_upload({
                    platform: 'android',
                    sauce_username: 'foo',
                    sauce_access_key: 'bar123',
                    app: 'Android.MyCustomApp.apk',
                    file: '',
                    region: 'eu'
                  })
          end").runner.execute(:test)

      end.to raise_error("No file path given, set using: app_path: 'path/to/my/testApp.apk'")
    end

    it "should raise an error when no app_name is specified" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_upload({
                     platform: 'android',
                     sauce_username: 'foo',
                     sauce_access_key: 'bar',
                     app: '',
                     file: '#{@file}',
                     region: 'eu'
                   })
          end").runner.execute(:test)

      end.to raise_error("No App name given, set using: app_name: 'testApp.apk'")
    end

    it "should raise an error when invalid region is specified" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_upload({
                         platform: 'android',
                         sauce_username: 'foo',
                         sauce_access_key: 'bar',
                         app: 'Android.MyCustomApp.apk',
                         file: '#{@file}',
                         region: 'foobar'
                       })
          end").runner.execute(:test)

      end.to raise_error("foobar is an invalid region. Supported regions are 'us' and 'eu'")
    end

    it "should raise an error when no sauce username is specified" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_upload({
                     platform: 'android',
                     sauce_username: '',
                     sauce_access_key: 'bar',
                     app: 'Android.MyCustomApp.apk',
                     file: '#{@file}',
                     region: 'eu'
                   })
          end").runner.execute(:test)

      end.to raise_error("No sauce labs username provided, set using: sauce_username: 'sauce user name', or consider setting your credentials as environment variables.")
    end

    it "should raise an error when no sauce access key is specified" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          sauce_upload({
                     platform: 'android',
                     sauce_username: 'foo',
                     sauce_access_key: '',
                     app: 'Android.MyCustomApp.apk',
                     file: '#{@file}',
                     region: 'eu'
                   })
          end").runner.execute(:test)

      end.to raise_error("No sauce labs access key provided, set using: sauce_access_key: '1234' or consider setting your credentials as environment variables.")
    end
  end
end
