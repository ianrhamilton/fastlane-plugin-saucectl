require_relative "spec_helper"

describe "run tests" do

  it "should return package, class and test case array" do

    # upload apps and get ids
    upload_id = Fastlane::FastFile.new.parse("lane :test do
          sauce_upload({platform: 'android',
                        app: 'mda-1.0.10-12.apk',
                        file: '/Users/ian/Documents/workspace/fastlane-plugin-saucectl/my-demo-app-android/mda-1.0.10-12.apk',
                        region: 'eu'
             })
        end").runner.execute(:test)

    runner_id = Fastlane::FastFile.new.parse("lane :test do
          sauce_upload({platform: 'android',
                        app: 'mda-androidTest-1.0.10-12.apk',
                        file: '/Users/ian/Documents/workspace/fastlane-plugin-saucectl/my-demo-app-android/mda-androidTest-1.0.10-12.apk',
                        region: 'eu'
             })
        end").runner.execute(:test)

    # create config
    Fastlane::FastFile.new.parse("lane :test do
          sauce_config({ platform: 'android',
                         kind: 'espresso',
                         app_path: 'storage:#{upload_id}',
                         app: 'myTestApp.apk',
                         test_app: 'storage:#{runner_id}',
                         path_to_tests: '#{File.expand_path("../my-demo-app-android/app/src/androidTest")}',
                         region: 'eu',
                         emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: %w[10.0 11.0], orientation: 'portrait'}]
      })
      end").runner.execute(:test)

    # run tests
    Fastlane::FastFile.new.parse("lane :test do
          install_toolkit
      end").runner.execute(:test)

    # run tests
    Fastlane::FastFile.new.parse("lane :test do
          sauce_runner
      end").runner.execute(:test)

    # delete apk
    response = Fastlane::FastFile.new.parse("lane :test do
          delete_from_storage({
                    region: 'eu',
                    platform: 'android',
                    app_name: 'Android.MyCustomApp.apk',
                    app_id: '#{upload_id}'
                  })
        end").runner.execute(:test)

    puts "deleted app with id #{response}"

    # delete apk
    response_2 = Fastlane::FastFile.new.parse("lane :test do
          delete_from_storage({
                    region: 'eu',
                    platform: 'android',
                    app_name: 'Android.MyCustomApp.apk',
                    app_id: '#{runner_id}'
                  })
        end").runner.execute(:test)

    puts "deleted app with id #{response_2}"

  end

  it "should get all android devices" do

    response = Fastlane::FastFile.new.parse("lane :test do
          sauce_devices({platform: 'android',
                         region: 'eu'})
        end").runner.execute(:test)

    p response

  end

  it "should get all ios devices" do

    response = Fastlane::FastFile.new.parse("lane :test do
          sauce_devices({platform: 'ios',
                         region: 'eu'})
        end").runner.execute(:test)

    p response

  end

  it "should get all devices" do

    response = Fastlane::FastFile.new.parse("lane :test do
          sauce_devices({region: 'eu'})
        end").runner.execute(:test)

    p response

  end

  it "should get all android apps" do

    response = Fastlane::FastFile.new.parse("lane :test do
          sauce_apps({
                    platform: 'android',
                    query: 'Emirates-staging-debug.apk',
                    region: 'eu'})
        end").runner.execute(:test)

    p response.body

  end

  it "should get all ios apps" do

    response = Fastlane::FastFile.new.parse("lane :test do
          sauce_apps({
                    platform: 'ios',
                    query: 'Emirates-staging-debug.apk',
                    region: 'eu'})
        end").runner.execute(:test)

    p response.body

  end

end
