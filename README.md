# fastlane-plugin-saucectl

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-saucectl)
[![codecov](https://codecov.io/gh/ianrhamilton/fastlane-plugin-rsaucectl/branch/main/graph/badge.svg?token=NSVhqgYFYv)](https://codecov.io/gh/ianrhamilton/fastlane-plugin-saucectl)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-saucectl`, add it to your project by running:

```bash
fastlane add_plugin saucectl
```

## About fastlane-plugin-saucectl

The purpose of this plugin is to simplify the set up, configuration, upload, and execution of espresso and XCUITest on the Sauce Labs platform by utilizing fastlane which will enable you to test your iOS and Android apps at scale.

**IMPORTANT:** in order for you to use this plugin to execute UI tests, your test class names must proceed with Spec, Specs, Tests, or Test, for example ExampleSpec, ExampleSpecs, ExampleTest, ExampleTests. Your test case names must also begin with test, for example testIDoSomething, testIDoSomethingElse. This is so that the the plugin can search for test classes and their included test cases.

Failure to do this will result in missing test classes and test cases from your test run.

**For a detailed introduction to each of the actions available within this plugin, please see the [documentation](https://ianrhamilton.github.io/fastlane-plugin-saucectl/#fastlane-plugin-saucectl)**.

| Available Actions   | Description                                                                                                                                                                                            |
|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `install_saucectl`    | Downloads the Sauce Labs saucectl cli binary for test execution                                                                                                                                        |
| `sauce_upload`        | Upload test artifacts to sauce labs storage                                                                                                                                                            | 
| `sauce_config`        | Create SauceLabs configuration file for test execution based on given parameters                                                                                                                       |
| `sauce_runner`        | Execute automated tests on sauce labs platform via saucectl binary for specified configuration                                                                                                         | 
| `delete_from_storage` | Delete test artifacts from sauce labs storage by storage id or group id                                                                                                                                |
| `sauce_apps`          | Returns the set of files by specific app id that have been uploaded to Sauce Storage by the requester                                                                                                  |
| `sauce_devices`       | Returns a list of Device IDs for all devices in the data center that are currently free for testing.                                                                                                   |
| `disabled_tests`      | Fetches any disabled ui test cases (for android searches for @Ignore tests, and for ios skipped tests within an xcode test plan). Plan is to use this in the future for generating pretty HTML reports | 

An order of which you may utilize the above actions in your continuous integration platform could be:
1. Install the saucectl binary via `install_saucectl`
2. Upload your test artifacts to Sauce Labs storage (for example app apk, and test runner apk)
3. Create config.yml for given parameters via `sauce_config` 
4. Execute test based on specified config via `sauce_runner`
5. Delete test artifacts via `delete_from_storage` so that your storage does not fill up (if you're executing tests on every PR, for example)

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

**Note to author:** Please set up a sample project to make it easy for users to explore what your plugin does. Provide everything that is necessary to try out the plugin in this project (including a sample Xcode/Android project if necessary)

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## Buy me a coffee
If you're enjoying this plugin, feel free to **optionally** buy me a coffee :) 

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/ianrhamilton)
