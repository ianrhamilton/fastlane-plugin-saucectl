# fastlane-plugin-saucectl

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-saucectl)
[![codecov](https://codecov.io/gh/ianrhamilton/fastlane-plugin-rsaucectl/branch/main/graph/badge.svg?token=NSVhqgYFYv)](https://codecov.io/gh/ianrhamilton/fastlane-plugin-saucectl)
## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-saucectl`, add it to your project by running:

```bash
fastlane add_plugin saucectl
```

## About fastlane-plugin-saucectl

The purpose of this plugin is to simplify the set up, configuration, upload, and execution of espresso and xcuitests via the [Sauce Labs](https://saucelabs.com/) platform by utilizing fastlane which will enable you to test your iOS and and Android apps at scale using [Sauce Labs CLI](https://docs.saucelabs.com/dev/cli/saucectl/).

| Available Actions   | Description                                                                                                                                                                                            |
|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| install_toolkit     | Downloads the Sauce Labs saucectl cli binary for test execution                                                                                                                                        |
| sauce_upload        | Upload test artifacts to sauce labs storage                                                                                                                                                            | 
| sauce_config        | Create SauceLabs configuration file for test execution based on given parameters                                                                                                                       |
| sauce_runner        | Execute automated tests on sauce labs platform via saucectl binary for specified configuration                                                                                                         | 
| delete_from_storage | Delete test artifacts from sauce labs storage by storage id or group id                                                                                                                                |
| sauce_apps          | Returns the set of files by specific app id that have been uploaded to Sauce Storage by the requester                                                                                                  |
| sauce_devices       | Returns a list of Device IDs for all devices in the data center that are currently free for testing.                                                                                                   |
| disabled_tests      | Fetches any disabled ui test cases (for android searches for @Ignore tests, and for ios skipped tests within an xcode test plan). Plan is to use this in the future for generating pretty HTML reports | 

An order of which you may utilize the above actions in your continuous integration platform could be:
1. Install the saucectl binary via `install_toolkit`
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
