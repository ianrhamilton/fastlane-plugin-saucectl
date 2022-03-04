require_relative "spec_helper"

describe "run tests" do
  it "should return package, class and test case array for android virtual devices" do
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
                         app: 'storage:#{upload_id}',
                         test_app: 'storage:#{runner_id}',
                         path_to_tests: '#{File.expand_path('../my-demo-app-android/app/src/androidTest')}',
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

  # ______________________
  # IOS
  # ______________________
  it "should return package, class and test case array for ios real devices" do
    # # upload apps and get ids
    # upload_id = Fastlane::FastFile.new.parse("lane :test do
    #       sauce_upload({platform: 'ios',
    #                     app: 'SauceLabs-Demo-App.ipa',
    #                     file: '/Users/ian.hamilton/Documents/fastlane-plugin-saucectl/my-demo-app-ios/SauceLabs-Demo-App.ipa',
    #                     region: 'eu'
    #          })
    #     end").runner.execute(:test)
    #
    # puts "UPLOAD ID WAS #{upload_id}"
    #
    # runner_id = Fastlane::FastFile.new.parse("lane :test do
    #       sauce_upload({platform: 'ios',
    #                     app: 'SauceLabs-Demo-App-Runner.XCUITest.ipa',
    #                     file: '/Users/ian.hamilton/Documents/fastlane-plugin-saucectl/my-demo-app-ios/SauceLabs-Demo-App-Runner.XCUITest.ipa',
    #                     region: 'eu'
    #          })
    #     end").runner.execute(:test)
    #
    # puts "RUNNER ID WAS #{runner_id}"

    # create config
    # Fastlane::FastFile.new.parse("lane :test do
    #       sauce_config({ platform: 'ios',
    #                      kind: 'xcuitest',
    #                      app:  '/Users/ian.hamilton/Documents/fastlane-plugin-saucectl/my-demo-app-ios/SauceLabs-Demo-App.ipa',
    #                      test_app: '/Users/ian.hamilton/Documents/fastlane-plugin-saucectl/my-demo-app-ios/SauceLabs-Demo-App-Runner.XCUITest.ipa',
    #                      test_target: 'My_Demo_AppUITests',
    #                      max_concurrency_size: 2,
    #                      region: 'eu',
    #                      test_distribution: 'class',
    #                      devices: [ {id: 'iPhone_13_mini_15_real'}, {id: 'iPhone_12_mini_15_real'}]
    #   })
    #   end").runner.execute(:test)

    #           install_toolkit
    # Fastlane::FastFile.new.parse("lane :test do
    #       install_toolkit
    #   end").runner.execute(:test)

    # run tests
    Fastlane::FastFile.new.parse("lane :test do
          sauce_runner
      end").runner.execute(:test)

    # # delete apk
    # response = Fastlane::FastFile.new.parse("lane :test do
    #       delete_from_storage({
    #                 region: 'eu',
    #                 platform: 'ios',
    #                 app_name: 'SauceLabs-Demo-App.ipa',
    #                 app_id: '#{upload_id}'
    #               })
    #     end").runner.execute(:test)
    #
    # puts "deleted app with id #{response}"

    # # delete apk
    # response_2 = Fastlane::FastFile.new.parse("lane :test do
    #       delete_from_storage({
    #                 region: 'eu',
    #                 platform: 'ios',
    #                 app_name: 'SauceLabs-Demo-App-Runner.XCUITest.ipa',
    #                 app_id: '#{runner_id}'
    #               })
    #     end").runner.execute(:test)
    #
    # puts "deleted app with id #{response_2}"
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
                    query: 'mda-1.0.10-12.apk',
                    region: 'eu'})
        end").runner.execute(:test)

    p response.body
  end
end
