# require_relative "spec_helper"
#
# describe "run tests" do
#
#   it "should return package, class and test case array" do
#
#     # "/Users/ian/Documents/workspace/fastlane-plugin-saucectl/my-demo-app-android/mda-1.0.10-12.apk"
#     # testApp: "/Users/ian/Documents/workspace/fastlane-plugin-saucectl/my-demo-app-android/mda-androidTest-1.0.10-12.apk"
#
#     upload_id = Fastlane::FastFile.new.parse("lane :test do
#           sauce_upload({platform: 'android',
#                         app: 'mda-1.0.10-12.apk',
#                         file: '/Users/ian/Documents/workspace/fastlane-plugin-saucectl/my-demo-app-android/fail.apk',
#                         region: 'eu'
#              })
#         end").runner.execute(:test)
#
#     puts upload_id
#
#   end
# end
