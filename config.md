---
layout: page
title: Configuration
permalink: /config/
---

### Sauce Config
Sauce Labs uses its framework agnostic test orchestrator saucectl in order to execute Espresso and XCUITest tests based on one or more configuration files. Saucectl relies on a YAML specification file to determine exactly which tests to run and how to run them. 

Using this plugin you can automatically generate the required configuration file using the `sauce_config` action.

This page defines each of the configuration parameters that is required, or optionally properties specific to running tests.

### Supported test frameworks
    1. Espresso
    2. XCUITest

### Configuring Tests using `sauce_config`

## `platform`
> Application under test platform

| Required | ***true***         |
| Type     | ***String***       |
| Options  | ***ios, android*** |

_______________________________________

## `kind`
> Specifies which framework is associated with the automation tests configured in this specification

| Required | ***true***         |
| Type     | ***String***       |
| Options  | ***espresso, xcuitest*** |

_______________________________________

## `app`
> The path to the application under test

| Required | ***true***         |
| Type     | ***String***       |

_______________________________________

## `test_app`
> The path to the testing application (test runner)

| Required | ***true***         |
| Type     | ***String***       |

_______________________________________

## `region`
> Data Center region (us or eu), set using: region: 'eu'

| Required | ***true***         |
| Type     | ***String***       |
| Options  | ***us, eu***       |

_______________________________________

## `retries`
> Sets the number of times to retry a failed suite

| Optional | ***true***         |
| Type     | ***Integer***      |

_______________________________________

## `test_distribution`
> Test run distribution method. 

### Why distribute tests?
One of the main drawbacks of the native sauce platform is the long running test run or suite videos. Long running videos make it difficult to debug failures,
for example; if you have a single suite of tests that takes 10 minutes to execute, and that execution contains a single failure, you would need need scroll through a ten minute video in order to view the test failure. This can be quite frustrating!
If you distribute suites by test case it may take slightly longer, however you will save far more time debugging failures, and can save and share a short video of the exact failure.

## Espresso Test distribution options

The Saucectl plugin will scan the specified path to tests for test classes, test cases, or packages. 
The plugin will then instruct saucectl to treat each specified option as a suite per specified device(s) or virtual device(s).

| class    | Considers 1 test class to 1 suite per device or virtual device under test        |
| testCase | Considers 1 test case equal to 1 suite per device or virtual device under test       |
| package  | Considers 1 package equal to 1 suite per device or virtual device under test |
| shard    | Distributes test cases evenly between number of devices or emulators |

**Example**

    test_distribution: 'testCase'

Default: `class`

## XCUITest Test distribution options

The Saucectl plugin has the capabilities to either read a user specified Test Plan, or scan a UI Test target for test classes, and test cases. 
The plugin will then instruct saucectl to treat each specified option as a suite per specified real device(s).

| class     | Considers 1 class equal to 1 suite per device or virtual device under test      |
| testCase  | Considers 1 test case equal to 1 suite per device or virtual device under test  |
| shard     | Distributes test cases evenly between number of real devices  |

**Example**
    
    test_distribution: 'testCase'

Default: `class`

_______________________________________

## `test_class`
> Instructs saucectl to only run the specified classes for this test suite.

| Optional | ***true***         |
| Type     | ***Array***        |

**Example**

    test_class: ['com.some.package.testing.SomeClassOne', 'com.some.package.testing.SomeClassTwo', 'com.some.package.testing.SomeClassThree', 'com.some.package.testing.SomeClassFour']

_______________________________________

## `emulators`
> The parent property that defines details for running this suite on [virtual devices](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#emulators) using an emulator. NOTE: only supported on the android platform.

| Optional | ***true***         |
| Type     | ***Array***        |

Required parameters for virtual devices:

| name                  | name of the virtual device | ***String***       |
| platform_versions     | platform version(s)        | ***Array***        |

**Example**

    emulators:  [ {name: 'Android GoogleApi Emulator One', platform_versions: ['11.0']}, {name: Android GoogleApi Emulator Two', platform_versions: ['13.0']}],

Optional parameter for virtual devices:

`orientation`
> The screen orientation to use while executing this test suite on this virtual device. Valid values are portrait or landscape.

_______________________________________

## `devices`

> The parent property that defines details for running this suite on [real devices](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#devices). You can request a specific device using its ID, or you can specify a set of criteria to choose the first available device that matches the specifications.

| Optional | ***true***         |
| Type     | ***Array***        |

When an ID is specified, it supersedes the other settings.

[`id`](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#id)
> Request a specific device for this test suite by its ID.

| Optional | ***true***         |
| Type     | ***String***        |

**Example**

    devices: [ {id: 'Google_Pixel_2_real_us'} ]

[`name`](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#name-3)
> Find a device for this test suite that matches the device name or portion of the name, which may provide a larger pool of available devices of the type you want.

| Optional | ***true***         |
| Type     | ***String***        |

**Example** 

Complete Name:

    devices: [ {name: 'Google Pixel 4 XL'} ]

Pattern Matching:
    
    devices: [ {name: 'Google Pixel.*'} ]

[`platformVersion`](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#platformversion)
> Request that the device matches a specific platform version.

| Optional | ***true***         |
| Type     | ***String***       |

**Example**

    devices: [ {name: 'Google Pixel.*', platformVersion: 8.0} ]

`orientation`
> The orientation of the device. Default: portrait

**Example**

    devices: [ {name: 'Google Pixel.*', platformVersion: 8.0, orientation: 'landscape' } ]

`device_type`
> Request that the matching device is a specific type of device. Valid values are: ANY TABLET PHONE any tablet phone

**Example**

    devices: [ {name: 'Google Pixel.*', platformVersion: 8.0, device_type: 'TABLET' } ]

`private`
> Request that the matching device is from your organization's private pool only. Default: TRUE

**Example**

    devices: [ {name: 'Google Pixel.*', platformVersion: 8.0, private: false } ]

`carrier_connectivity`
> Request that the matching device is also connected to a cellular network. Default: false

**Example**

    devices: [ {name: 'Google Pixel.*', platformVersion: 8.0, carrier_connectivity: true } ]

_______________________________________

## `test_target`

> **iOS only**: Name of the Xcode test target name in order to scan for test classes and test cases to execute via your chosen test distribution method

| Optional | ***true***         |
| Type     | ***String***       |

**Example**

    test_target: 'NameOfMyUITests'

## `test_plan`

> **iOS only**: Name of the Xcode test plan containing the tests that you wish to test/skip via your chosen test distribution method.

| Optional | ***true***         |
| Type     | ***String***       |

**Example**

    test_plan: 'NameOfMyTestPlan'

** Note: You must specify a test plan or test target.

_____________________________________________________________

## `path_to_tests`






