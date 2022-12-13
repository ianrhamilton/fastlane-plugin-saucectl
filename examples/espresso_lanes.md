---
layout: default
title: Espresso Example
nav_order: 1
parent: Fastlane Examples
---

# Espresso Example

This is an example provides each of the `lanes` that can be utilized within your `Fastfile` for your android apps.

## Upload app and test runner to Sauce Labs storage

```ruby
    desc "Upload app and test runner to Sauce Labs storage"
    lane :upload_to_sauce do
        @app_id = sauce_upload(platform: 'android',
                               app: 'MyTestApp.apk',
                               file: 'app/build/outputs/apk/MyTestApp.apk',
                               region: 'eu',
                               sauce_username: ENV['SAUCE_USERNAME'],
                               sauce_access_key: ENV['SAUCE_ACCESS_KEY'])

        @test_app_id = sauce_upload(platform: 'android',
                                    app: 'MyTestApp-androidTest.apk',
                                    file: 'app/build/outputs/apk/androidTest/MyTestApp-androidTest.apk',
                                    region: 'eu',
                                    sauce_username: ENV['SAUCE_USERNAME'],
                                    sauce_access_key: ENV['SAUCE_ACCESS_KEY'])

    end
```

## Install latest version of Sauce Labs toolkit saucectl runner executable  

```ruby
    
    desc "Install Sauce Labs toolkit dependencies"
        lane :install do
        install_saucectl
    end

```

## Install specific version of Sauce Labs toolkit saucectl runner executable  

```ruby

    desc "Install Sauce Labs toolkit dependencies"
        lane :install_toolkit do
        install_saucectl(version: '0.86.0')
    end 

```

## Create configuration for Virtual Device execution

```ruby
    desc "Create saucectl configuration for Virtual Device execution"
        lane :generate_sauce_config do |options|
            sauce_config(platform: 'android',
                         kind: 'espresso',
                         app: "storage:#{@app_id}",
                         test_app: "storage:#{@test_app_id}",
                         path_to_tests: 'app/src/androidTest/',
                         max_concurrency_size: 30,
                         region: 'eu',
                         test_distribution: 'testCase',
                         emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: ['11.0']}])
    end

```

# Execute UI tests on sauce labs platform

The below lane will execute tests based on your configuration (`config.yml`)

```ruby 

    desc "Execute UI tests on sauce labs platform"
        lane :execute_tests do
        sauce_runner
    end

```

# Delete apps from Sauce Labs storage


If you have these tests running in a continuous integration environment that may be executed one to many times per day, I suggest deleting apps from storage post test run, so that you do not run into any storage issues later down the line. The below lane can be used to delete test runner and application apk's.

```ruby

    desc "Delete apps from Sauce Labs storage"
    lane :delete_apps do

          delete_from_storage(region: 'eu',
                              sauce_username: ENV['SAUCE_USERNAME'],
                              sauce_access_key: ENV['SAUCE_ACCESS_KEY'],
                              app_id: @app_id)

          delete_from_storage(region: 'eu',
                              sauce_username: ENV['SAUCE_USERNAME'],
                              sauce_access_key: ENV['SAUCE_ACCESS_KEY'],
                              app_id: @test_app_id)
    end

```

## Putting it all together - example

<details>
<summary>Fastfile</summary>
<pre>

```ruby

# This is an example fastlane file in order to demo how you would use this plugin minimum version number required.
# Update this, if you use features of a newer version
fastlane_version "2.82.0"

default_platform :android

platform :android do

    before_all do |lane, options|
        upload_to_sauce
    end

    desc "Execute ui tests using virtual devices"
    lane :pull_request_tests do
        generate_sauce_config
        install
        execute_tests
    end

    desc "Upload app and test runner to Sauce Labs storage"
    lane :upload_to_sauce do
        @app_id = sauce_upload(platform: 'android',
                               app: 'MyTestApp.apk',
                               file: 'app/build/outputs/apk/MyTestApp.apk',
                               region: 'eu',
                               sauce_username: ENV['SAUCE_USERNAME'],
                               sauce_access_key: ENV['SAUCE_ACCESS_KEY'])

        @test_app_id = sauce_upload(platform: 'android',
                                    app: 'MyTestApp-androidTest.apk',
                                    file: 'app/build/outputs/apk/androidTest/MyTestApp-androidTest.apk',
                                    region: 'eu',
                                    sauce_username: ENV['SAUCE_USERNAME'],
                                    sauce_access_key: ENV['SAUCE_ACCESS_KEY'])

    end

    desc "Create saucectl configuration for Virtual Device execution"
        lane :generate_sauce_config do |options|
            sauce_config(platform: 'android',
                         kind: 'espresso',
                         app: "storage:#{@app_id}",
                         test_app: "storage:#{@test_app_id}",
                         path_to_tests: 'app/src/androidTest/',
                         max_concurrency_size: 30,
                         region: 'eu',
                         test_distribution: 'testCase',
                         emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: ['11.0']}])
    end

    desc "Install Sauce Labs toolkit dependencies"
        lane :install do
             install_saucectl
    end

    desc "Execute UI tests on sauce labs platform"
        lane :execute_tests do
             sauce_runner
    end

    desc "Delete apps from Sauce Labs storage"
    lane :delete_apps do

          delete_from_storage(region: 'eu',
                              sauce_username: ENV['SAUCE_USERNAME'],
                              sauce_access_key: ENV['SAUCE_ACCESS_KEY'],
                              app_id: @app_id)

          delete_from_storage(region: 'eu',
                              sauce_username: ENV['SAUCE_USERNAME'],
                              sauce_access_key: ENV['SAUCE_ACCESS_KEY'],
                              app_id: @test_app_id)
    end

    after_all do |lane, options|
        delete_apps
    end
end

```
</pre>
</details>

---------------------------------------------------------------------
