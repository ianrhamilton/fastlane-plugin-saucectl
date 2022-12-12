---
layout: default
title: Configuration
nav_order: 3
has_children: true
---
# Sauce Config action

Sauce Labs uses its framework agnostic test orchestrator `saucectl` in order to execute Espresso and XCUITest tests based on one or more configuration files. `saucectl` relies on a YAML specification file to determine exactly which tests to run and how to run them.

Using this plugin you can automatically generate and customize the required configuration file using the fastlane `sauce_config` action.
