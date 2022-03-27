---
layout: page
title: Configuration
permalink: /config/
---

# Sauce Config action
Sauce Labs uses its framework agnostic test orchestrator saucectl in order to execute Espresso and XCUITest tests based on one or more configuration files. Saucectl relies on a YAML specification file to determine exactly which tests to run and how to run them.

Using this plugin you can automatically generate the required configuration file using the fastlane `sauce_config` action.

**Please NOTE in order for you to use this plugin to execute UI tests, your test class names must proceed with `Spec`, `Specs`, `Tests`, or `Test`**, for example `ExampleSpec`, `ExampleSpecs`, `ExampleTest`, `ExampleTests`. 
**Your test case names must also begin with `test`**, for example `testIDoSomething`, `testIDoSomethingElse`. This is so that the the plugin can search for test classes and their included test cases.

**Failure to do this will result in missing test classes and test cases from your test run**.

This page defines each of the configuration parameters that is required, or optionally properties specific to running tests.

# Supported test frameworks
    1. Espresso
    2. XCUITest

# Help
Information and help for the `sauce_config` action can be printed out by executed the following command:
```sh
fastlane action sauce_config
```

--------------------------------------------------------------------
# Parameters

## `platform`

| Required   | Type     | Description                     | Options         |
|------------|----------|---------------------------------|-----------------|
| ***true*** | `String` | Application under test platform | `ios`,`android` |   

---------------------------------------------------------------------
## `kind`

| Required   | Type     | Description                                                                                        | Options               |
|------------|----------|----------------------------------------------------------------------------------------------------|-----------------------|
| ***true*** | `String` | Specifies which framework is associated with the automation tests configured in this specification | `espresso`,`xcuitest` |   

---------------------------------------------------------------------
## `app`

| Required   | Type     | Description                            | 
|------------|----------|----------------------------------------|
| ***true*** | `String` | The path to the application under test |

---------------------------------------------------------------------
## `test_app`

| Required   | Type     | Description                                       | 
|------------|----------|---------------------------------------------------|
| ***true*** | `String` | The path to the testing application (test runner) |

---------------------------------------------------------------------
## `region`

| Required   | Type     | Description                                            | Options   |
|------------|----------|--------------------------------------------------------|-----------|
| ***true*** | `String` | Data Center region (us or eu), set using: region: 'eu' | `us`,`eu` |   

---------------------------------------------------------------------
## `retries`

| Required    | Type      | Description                                      | 
|-------------|-----------|--------------------------------------------------|
| ***false*** | `Integer` | Sets the number of times to retry a failed suite |

---------------------------------------------------------------------
## `test_distribution`

| Required    | Type     | Description                   | Default Method |
|-------------|----------|-------------------------------|----------------|
| ***false*** | `String` | Test run distribution method. | `class`        |

### Why distribute tests?
One of the only drawbacks of the native sauce platform is the long running test runs or suite videos. Long running videos make it difficult to debug failures,
for example; if you have a single suite of tests that takes 10 minutes to execute, and that execution contains a single failure, you would need need scroll through a ten minute video in order to view the test failure. This can be quite frustrating!
If you distribute suites by test case it may take slightly longer, however you will save far more time debugging failures, and can save and share a short video of the exact failure.

## Espresso Test distribution options

The saucectl plugin will scan the specified path to tests for test classes, test cases, or packages. 
The plugin will then instruct saucectl to treat each specified option as a suite per specified device(s) or virtual device(s).

| Distribution method       | Description                                                                    | 
|---------------------------|--------------------------------------------------------------------------------|
| `testCase`                | Considers 1 test case equal to 1 suite per device or virtual device under test |
| `class`                   | Considers 1 test class to 1 suite per device or virtual device under test      |
| `package`                 | Considers 1 package equal to 1 suite per device or virtual device under test   |
| `shard`                   | Distributes test cases evenly between n number of devices or emulators         |

## Example

### `test_distribution: 'testCase'`

![testCase distribution for virtual devices](../assets/saucectl_test_case.drawio.png?raw=true "testCase")

**Please note**, this is only recommended when executing tests via **virtual devices**. The reason for this is because they can be scaled based on your `max_concurrency`. This is of course unless you're lucky enough to have multiple of the same device and OS combinations that you can execute at scale.

For example, given your project has three test cases, and I create a config with the following config:

```ruby
lane :create_config do
    sauce_config(platform: 'android',
                 kind: 'espresso',
                 app: 'path/to/myTestApp.apk',
                 test_app: 'path/to/myTestRunner.apk',
                 path_to_tests: 'my-demo-app-android/app/src/androidTest',
                 max_concurrency: 3,
                 test_distribution: 'testCase',
                 region: 'eu',
                 emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: ['11.0']}]
             )
end
```

Would produce:

```yaml
---
apiVersion: v1alpha
kind: espresso
retries: 0
sauce:
  region: eu-central-1
  concurrency: 3
  metadata:
    name: testing/somebuild-name-15
    build: 'Release '
espresso:
  app: path/to/myTestApp.apk
  testApp: path/to/myTestRunner.apk
artifacts:
  download:
    when: always
    match:
    - junit.xml
    directory: "./artifacts/"
reporters:
  junit:
    enabled: true
suites:
- name: testing/somebuild-name-15-testClass#testCaseOne
  testOptions:
    class: com.my.project.TestClass#testCaseOne
    clearPackageData: true
    useTestOrchestrator: true
  emulators:
  - name: Android GoogleApi Emulator
    orientation: portrait
    platformVersions:
    - '11.0'
- name: testing/somebuild-name-15-testClass#testCaseTwo
  testOptions:
    class: com.my.project.TestClass#testCaseTwo
    clearPackageData: true
    useTestOrchestrator: true
  emulators:
    - name: Android GoogleApi Emulator
      orientation: portrait
      platformVersions:
        - '11.0'
- name: testing/somebuild-name-15-testClass#testCaseThree
  testOptions:
    class: com.my.project.TestClass#testCaseThree
    clearPackageData: true
    useTestOrchestrator: true
  emulators:
    - name: Android GoogleApi Emulator
      orientation: portrait
      platformVersions:
        - '11.0'
```

## `test_distribution: 'class'`

![test class distribution](../assets/saucectl_test_class.drawio.png?raw=true "class")

For example, given your project has three test classes, and I create a config with the following config:

```ruby
lane :create_config do
    sauce_config(platform: 'android',
                 kind: 'espresso',
                 app: 'path/to/myTestApp.apk',
                 test_app: 'path/to/myTestRunner.apk',
                 path_to_tests: 'my-demo-app-android/app/src/androidTest',
                 max_concurrency: 3,
                 test_distribution: 'class',
                 region: 'eu',
                 emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: ['11.0']}]
             )
end
```

The saucectl plugin will gather all test classes and **will create a suite for each class**. 

```yaml
---
apiVersion: v1alpha
kind: espresso
retries: 0
sauce:
  region: eu-central-1
  concurrency: 3
  metadata:
    name: testing/somebuild-name-15
    build: 'Release '
espresso:
  app: path/to/myTestApp.apk
  testApp: path/to/myTestRunner.apk
artifacts:
  download:
    when: always
    match:
    - junit.xml
    directory: "./artifacts/"
reporters:
  junit:
    enabled: true
suites:
- name: testing/somebuild-name-15-testClassOne
  testOptions:
    class: com.some.test.TestClassOne
    clearPackageData: true
    useTestOrchestrator: true
  emulators:
  - name: Android GoogleApi Emulator
    orientation: portrait
    platformVersions:
    - '11.0'
- name: testing/somebuild-name-15-testClassTwo
  testOptions:
    class: com.some.test.TestClassTwo
    clearPackageData: true
    useTestOrchestrator: true
  emulators:
    - name: Android GoogleApi Emulator
      orientation: portrait
      platformVersions:
        - '11.0'
- name: testing/somebuild-name-15-testClassThree
  testOptions:
    class: com.some.test.TestClassThree
    clearPackageData: true
    useTestOrchestrator: true
  emulators:
    - name: Android GoogleApi Emulator
      orientation: portrait
      platformVersions:
        - '11.0'
```

Therefore the test run will be limited to each class, hence shortening the length of test suites and video recordings. 

## `test_distribution: 'shard'`

![test class distribution](../assets/saucectl_test_shard.drawio.png?raw=true "testCase")

Espresso and Sauce Labs have their [own implementation of test sharding](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#numshards) for parallel execution, this is **not the same**. The fastlane-plugin-saucectl supports cross platform sharding, and this implementation will gather test classes and distribute evenly between specified devices or virtual devices. 
For example, given your project has six test classes, and I create a config with the following config:

```ruby
lane :create_config do
 sauce_config(platform: 'android',
              kind: 'espresso',
              app: 'path/to/myTestApp.apk',
              test_app: 'path/to/myTestRunner.apk',
              path_to_tests: 'my-demo-app-android/app/src/androidTest',
              max_concurrency: 3,
              test_distribution: 'shard',
              region: 'eu',
              emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: ['11.0']}]
 )
end

```

The above config will enable parallel execution based on the given number of test classes and `devices` or `emulators`. In the above case it will distribute 6 classes across 3 emulators (6 / 3), therefore generating 3 suites.

--------------------------------------------------------------------

## XCUITest Test distribution options

The Saucectl plugin has the capabilities to either read a user specified Test Plan, or scan a UI Test target for test classes, and test cases. 
The plugin will then instruct saucectl to treat each specified option as a suite per specified real device(s).


| Distribution method       | Description                                                                    | 
|---------------------------|--------------------------------------------------------------------------------|
| `testCase`                | Considers 1 test case equal to 1 suite per device or virtual device under test |
| `class`                   | Considers 1 test class to 1 suite per device or virtual device under test      |
| `shard`                   | Distributes test cases evenly between number of devices or emulators           |

## `test_distribution: 'testCase'`

![testCase distribution](../assets/saucectl_test_ios_testcase.drawio.png?raw=true "testCase")

**Please note**, although this distribution method is available, it is **not recommended** for long running test suites. Hopefully in the future Sauce Labs will support virtual device testing for XCUITest, at that point this option will be useful as you can utilize your VM capacity. For now you can consider this as an experimental feature.

## `test_distribution: 'class'`

![testCase distribution](../assets/saucectl_test_ios_testclass.drawio.png?raw=true "testCase")

For example, given your project has three test classes, and I create a config with the following config:

```ruby
lane :create_config do
    sauce_config(platform: 'ios',
                 kind: 'xcuitest',
                 app: 'path/to/MyTestApp.ipa',
                 test_app: 'path/to/MyTestAppRunner.ipa',
                 region: 'eu',
                 devices: [ {name: 'iPhone 11'} ],
                 test_target: 'MyDemoAppUITests',
                 test_distribution: 'class'
                 )
end 
```

Would generate the following config that **creates a suite for each class**:

```yaml
apiVersion: v1alpha
kind: xcuitest
retries: 0
sauce:
  region: eu-central-1
  concurrency: 3
  metadata:
    name: testing/somebuild-name-15
    build: 'Release '
xcuitest:
  app: path/to/MyTestApp.ipa
  testApp: path/to/MyTestAppRunner.ipa
artifacts:
  download:
    when: always
    match:
    - junit.xml
    directory: "./artifacts/"
reporters:
  junit:
    enabled: true
suites:
- name: testing/somebuild-name-15-firstSpec
  testOptions:
    class: EmiratesUITests.FirstSpec
  devices:
  - name: 'iPhone 11'
    orientation: portrait
    options:
      carrierConnectivity: false
      deviceType: PHONE
      private: true
- name: testing/somebuild-name-15-secondSpec
  testOptions:
   class: EmiratesUITests.SecondSpec
  devices:
   - name: 'iPhone 11'
     orientation: portrait
     options:
      carrierConnectivity: false
      deviceType: PHONE
      private: true
- name: testing/somebuild-name-15-thirdSpec
  testOptions:
   class: EmiratesUITests.ThirdSpec
  devices:
   - name: 'iPhone 11'
     orientation: portrait
     options:
      carrierConnectivity: false
      deviceType: PHONE
      private: true
```

## `test_distribution: 'shard'`

There are two options for sharding XCUITests.
1. TestPlan
2. TestTarget

## TestPlan

It is possible to shard your UI tests when using Xcode test plan, therefore whatever test cases included in the test plan, the saucectl plugin will attempt to evenly distribute across your specified array of devices.  
![test class distribution](../assets/saucectl_ios_test_shard_test_plan.png "sharding by testPlan")

For example, given your testPlan has four enabled test classes and I create a config with the following config:

```ruby
lane :create_config do
  sauce_config(platform: 'ios',
               kind: 'xcuitest',
               app: 'path/to/MyTestApp.ipa',
               test_app: 'path/to/MyTestAppRunner.ipa',
               region: 'eu',
               devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
               test_plan: 'EnabledUITests',
               test_distribution: 'shard')
end 

```

Would produce the following config:

```yaml
---
apiVersion: v1alpha
kind: xcuitest
retries: 0
sauce:
  region: eu-central-1
  concurrency: 1
  metadata:
    name: unit-test-123
    build: 'Release '
xcuitest:
  app: "path/to/MyTestApp.ipa"
  testApp: "path/to/MyTestAppRunner.ipa"
artifacts:
  download:
    when: always
    match:
    - junit.xml
    directory: "./artifacts/"
reporters:
  junit:
    enabled: true
suites:
- name: unit-test-123-shard 1
  testOptions:
    class:
    - MyDemoAppUITests.SomeSpec/testTwo
    - MyDemoAppUITests.SomeSpec/testThree
  devices:
  - name: iPhone RDC One
    orientation: portrait
    options:
      carrierConnectivity: false
      deviceType: PHONE
      private: true
- name: unit-test-123-shard 2
  testOptions:
    class:
    - MyDemoAppUITests.SomeSpec/testFour
    - MyDemoAppUITests.SomeSpec/testFive
  devices:
  - id: iphone_rdc_two
    orientation: portrait
    options:
      carrierConnectivity: false
      deviceType: PHONE
      private: true
```

## `test_distribution: 'package'`
Instructs `saucectl` to run only tests in the specified package.

## TestTarget
When a `testTarget` is specified the saucectl plugin will scan the specified testTarget for test classes and will distribute evenly (where possible) across given array of devices.

![test class distribution](../assets/saucectl_ios_test_shard_testtarget.png "sharding by testPlan")

For example, given I create a config with the following:

```ruby
lane :create_config do
  sauce_config(platform: 'ios',
               kind: 'xcuitest',
               app: 'path/to/MyTestApp.ipa',
               test_app: 'path/to/MyTestAppRunner.ipa',
               region: 'eu',
               devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
               test_target: 'MyDemoAppUITests',
               test_distribution: 'shard')
end
```

Would produce the following config:

```yaml
---
apiVersion: v1alpha
kind: xcuitest
retries: 0
sauce:
  region: eu-central-1
  concurrency: 1
  metadata:
    name: unit-test-123
    build: 'Release '
xcuitest:
  app: "path/to/MyTestApp.ipa"
  testApp: "path/to/MyTestAppRunner.ipa"
artifacts:
  download:
    when: always
    match:
    - junit.xml
    directory: "./artifacts/"
reporters:
  junit:
    enabled: true
suites:
- name: unit-test-123-shard 1
  testOptions:
    class:
    - MyDemoAppUITests.NavigationTest
    - MyDemoAppUITests.ProductDetailsTest
  devices:
  - name: iPhone RDC One
    orientation: portrait
    options:
      carrierConnectivity: false
      deviceType: PHONE
      private: true
- name: unit-test-123-shard 2
  testOptions:
    class:
    - MyDemoAppUITests.ProductListingPageTest
  devices:
  - id: iphone_rdc_two
    orientation: portrait
    options:
      carrierConnectivity: false
      deviceType: PHONE
      private: true
```

----------------------------------------------------------------------------
## `size: '@LargeTest'`

**Android only**

Instructs `saucectl` to run only tests that are annotated with the matching size value i.e `@SmallTest`, `@MediumTest` or `@LargeTest`. Valid values are small, medium, or large. You may only specify one value for this property.

| Required | Type     | Description                                                                                                                                                                                                                                           | 
|----------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `false`  | `String` | Specify an size of tests to execute. |

**Example**

    size: '@LargeTest'

--------------------------------------------------------------------------

## `annotation: 'com.android.buzz.MyAnnotation'`

**Android only**

Instructs saucectl to run only tests that match a custom annotation that you have set.

| Required | Type     | Description                                                                                                                                                                                                                                           | 
|----------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `false`  | `String` | Specify an annotation of tests to execute. |

**Example**

    size: 'com.android.buzz.MyAnnotation'

--------------------------------------------------------------------------

## `test_class`

| Required | Type    | Description                                                                                                                                                                                                                                           | 
|----------|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `false`  | `Array` | Specify an array of tests to execute. |

**Android Example**

    test_class: ['com.some.package.testing.SomeClassOne', 'com.some.package.testing.SomeClassTwo', 'com.some.package.testing.SomeClassThree', 'com.some.package.testing.SomeClassFour']

**iOS Example**

    test_class: ['MyDemoAppUITests.SomeClassOne', 'MyDemoAppUITests.SomeClassTwo', 'MyDemoAppUITests.SomeClassThree', 'MyDemoAppUITests.SomeClassFour']

---------------------------------------------------------------------
## `emulators`

**Virtual device testing is only available on Android only**. 

| Required | Type    | Description                                                                                                                                                                                                                                           | 
|----------|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `false`  | `Array` | The parent property that defines details for running this suite on [virtual devices](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#emulators) using an emulator. NOTE: only supported on the android platform. |

Required parameters for virtual devices:

| Parameter         | Type     | Description                |
|-------------------|----------|----------------------------|
| name              | `String` | name of the virtual device |
| platform_versions | `Array`  | platform version(s)        |


**Example**

    emulators:  [ {name: 'Android GoogleApi Emulator One', platform_versions: ['11.0']}, {name: Android GoogleApi Emulator Two', platform_versions: ['13.0']}],

Optional parameter for virtual devices:

`orientation`
> The screen orientation to use while executing this test suite on this virtual device. Valid values are portrait or landscape.

---------------------------------------------------------------------
## `devices`


| Required | Type    | Description                                                                                                                                                                                                                                                                                                                                 | 
|----------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `false`  | `Array` | The parent property that defines details for running this suite on [real devices](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#devices). You can request a specific device using its ID, or you can specify a set of criteria to choose the first available device that matches the specifications. |


When an ID is specified, it supersedes the other settings.

[`id`](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#id)
> Request a specific device for this test suite by its ID.

| Optional | ***true***         |
| Type     | ***String***       |

**Example**

    devices: [ {id: 'Google_Pixel_2_real_us'} ]

[`name`](https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/espresso/#name-3)
> Find a device for this test suite that matches the device name or portion of the name, which may provide a larger pool of available devices of the type you want.

| Optional | ***true***         |
| Type     | ***String***       |

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
> The orientation of the device. Default: `portrait`

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

---------------------------------------------------------------------
## `test_target` (ios only)

| Required    | Type     | Description                                                                                                                             | 
|-------------|----------|-----------------------------------------------------------------------------------------------------------------------------------------|
| ***false*** | `String` | Name of the Xcode test target name in order to scan for test classes and test cases to execute via your chosen test distribution method |

**Example**

    test_target: 'NameOfMyUITests'

---------------------------------------------------------------------
## `test_plan` (ios only)

| Required    | Type     |     | Description                                                                                                           | 
|-------------|----------|:----|-----------------------------------------------------------------------------------------------------------------------|
| ***false*** | `String` |     | Name of the Xcode test plan containing the tests that you wish to test/skip via your chosen test distribution method. |

**Example**

    test_plan: 'NameOfMyTestPlan'

**Note: You must specify a test plan or test target.**

---------------------------------------------------------------------
## `path_to_tests` (android only)

| Required   | Type     |     | Description                                                                                                                                                                   | 
|------------|----------|:----|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ***true*** | `String` |     | Path to your espresso tests. Default: `currentDir/app/src/androidTest/`. This directory will be scanned and will collect tests based on your chosen test distribution method. |

**Example**

    test_plan: 'NameOfMyTestPlan'

---------------------------------------------------------------------
## `clear_data` (android only)

| Required    | Type      | Description                                                                                  | 
|-------------|-----------|----------------------------------------------------------------------------------------------|
| ***false*** | `Boolean` | Clear package data from device between suites (or test distribution method). Default: `true` |

**Example**

    clear_data: false

---------------------------------------------------------------------
## `use_test_orchestrator` (android only)

| Required    | Type      | Description                                     | 
|-------------|-----------|-------------------------------------------------|
| ***false*** | `Boolean` | User Android test orchestrator. Default: `true` |

**Example**

    use_test_orchestrator: false

---------------------------------------------------------------------
## `max_concurrency_size`

| Required    | Type      | Description                                  | 
|-------------|-----------|----------------------------------------------|
| ***false*** | `Integer` | User Android test orchestrator. Default: `1` |

**Example**

    max_concurrency_size: 20

---------------------------------------------------------------------
# Example actions

Create a config.yml file for android espresso based on user specified virtual device configurations
```ruby

lane :create_config do
    sauce_config({platform: 'android',
                  kind: 'espresso',
                  app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                  test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                  path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                  region: 'eu',
                  emulators: [ {name: 'Android GoogleApi Emulator', platform_versions: %w[10.0 11.0], orientation: 'portrait'}]
             })
end
```

---------------------------------------------------------------------
Create config.yml file for android espresso based on user specified real device configurations

```ruby
lane :create_config do
    sauce_config({platform: 'android',
                  kind: 'espresso',
                  app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                  test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                  path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                  region: 'eu',
                  test_distribution: 'testCase',
                  devices: [ {name: 'RDC One', orientation: 'portrait', platform_version: '11.0'}]
               })
end 
```

---------------------------------------------------------------------
Create config.yml file for android espresso based on user specified real device configurations

```ruby
lane :create_config do
    sauce_config({platform: 'android',
                  kind: 'espresso',
                  app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                  test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                  path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                  region: 'eu',
                  test_distribution: 'testCase',
                  devices: [ {name: 'RDC One', orientation: 'portrait', platform_version: '11.0'}]
               })
end 
```

---------------------------------------------------------------------
Create real device config.yml file for android platform with test distribution method as shard
```ruby
lane :create_config do
    sauce_config({platform: 'android',
                  kind: 'espresso',
                  app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                  test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                  path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                  region: 'eu',
                  test_distribution: 'shard',
                  devices: [ {name: 'RDC One', orientation: 'portrait', platform_version: '11.0'}]
                 })
end 
```

---------------------------------------------------------------------
Create config.yml file for real ios devices using xcode test target
```ruby
lane :create_config do
    sauce_config({platform: 'ios',
                  kind: 'xcuitest',
                  app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                  test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                  region: 'eu',
                  devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                  test_target: 'MyDemoAppUITests'
                 })
end 
```

---------------------------------------------------------------------
Create real device config.yml file for ios real devices using xcode test target and distribution method set as shard
```ruby
lane :create_config do
    sauce_config({platform: 'ios',
                  kind: 'xcuitest',
                  app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                  test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                  region: 'eu',
                  devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                  test_target: 'MyDemoAppUITests',
                  test_distribution: 'shard',
                 })
end 
```

---------------------------------------------------------------------
Create real device config.yml file for ios real devices using xcode test target and distribution method set as testCase

```ruby
lane :create_config do
      sauce_config({platform: 'ios',
                    kind: 'xcuitest',
                    app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                    test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                    region: 'eu',
                    devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                    test_target: 'MyDemoAppUITests',
                    test_distribution: 'testCase'
          })
end 
```

---------------------------------------------------------------------
Create real device config.yml file based on xcode test plan using sharding distribution method

```ruby
lane :create_config do
    sauce_config({platform: 'ios',
                  kind: 'xcuitest',
                  app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                  test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                  region: 'eu',
                  devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                  test_plan: 'EnabledUITests',
                  test_distribution: 'shard'
                 })
end 
```

---------------------------------------------------------------------
Create real device config.yml file based on xcode test plan using testCase distribution method

```ruby
lane :create_config do
    sauce_config({platform: 'ios',
                  kind: 'xcuitest',
                  app: '#{File.expand_path("my-demo-app-ios")}/MyTestApp.ipa',
                  test_app: '#{File.expand_path("my-demo-app-ios")}/MyTestAppRunner.ipa',
                  region: 'eu',
                  devices: [ {name: 'iPhone RDC One'}, {id: 'iphone_rdc_two'} ],
                  test_plan: 'UITests'
                 })
end 
```

---------------------------------------------------------------------
Specify an array of classes to execute on rdc

```ruby
lane :create_config do
    sauce_config({platform: 'android',
                  kind: 'espresso',
                  app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                  test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                  path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                  region: 'eu',
                  devices: [ {name: 'iPhone RDC One'}],
                  test_class: ['com.some.package.testing.SomeClassOne', 'com.some.package.testing.SomeClassTwo', 'com.some.package.testing.SomeClassThree', 'com.some.package.testing.SomeClassFour']
                })
end 
```

---------------------------------------------------------------------
Specify an array of classes to execute on virtual devices

```ruby
lane :create_config do
    sauce_config({platform: 'android',
                  kind: 'espresso',
                  app: '#{File.expand_path("my-demo-app-android")}/myTestApp.apk',
                  test_app: '#{File.expand_path("my-demo-app-android")}/myTestRunner.apk',
                  path_to_tests: '#{File.expand_path("my-demo-app-android/app/src/androidTest")}',
                  region: 'eu',
                  emulators: [ {name: 'iPhone RDC One', platform_versions: ['11.0']}, {name: 'iPhone RDC Two', platform_versions: ['11.0']}],
                  test_class: ['com.some.package.testing.SomeClassOne', 'com.some.package.testing.SomeClassTwo', 'com.some.package.testing.SomeClassThree', 'com.some.package.testing.SomeClassFour']
                 })
end 
```

---------------------------------------------------------------------
Specify an array of classes to execute on ios rdc

```ruby
lane :create_config do
    sauce_config({platform: 'ios',
                  kind: 'xcuitest',
                  app: '#{File.expand_path("my-demo-app-ios")}/myTestApp.app',
                  test_app: '#{File.expand_path("my-demo-app-ios")}/myTestRunner.app',
                  region: 'eu',
                  devices: [ {name: 'iPhone RDC One'}],
                  test_class: ['MyDemoAppUITests.SomeClassOne', 'MyDemoAppUITests.SomeClassTwo', 'MyDemoAppUITests.SomeClassThree', 'MyDemoAppUITests.SomeClassFour']
                 })
end 
```

---------------------------------------------------------------------
