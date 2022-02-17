require_relative 'spec_helper'

describe Fastlane::Actions::SauceConfigAction do
  describe 'saucelabs config action' do
    # before do
    #   @config = {}
    #   @config[:path_to_tests] = File.expand_path("my-demo-app-android/app/src/androidTest")
    # end

    after do
      # FileUtils.rm_rf('.sauce')
    end

    it 'should create config.yml file for android espresso based on user specified virtual device configurations' do
      Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app_path: 'Android.MyCustomApp.apk',
                         app_name: 'Android.MyCustomApp.apk',
                         test_runner_app: 'myTestRunner.apk',
                         path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         test_distribution: 'class',
                         is_virtual_device: true
          })
        end").runner.execute(:test)
    end
  end
end
