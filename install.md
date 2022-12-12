---
layout: default
title: Install saucectl binary
nav_order: 2
---

# Install Sauce Labs toolkit
Install Sauce Labs framework agnostic test orchestrator saucectl to execute Espresso and XCUITest tests. The latest version of the saucectl binary will be downloaded, however you can also specify the version (tag) of the version you wish to install. For a complete list of versions <a href="https://github.com/saucelabs/saucectl/releases/"> see </a>. 

# Help
Information and help for the `install_saucectl` action can be printed out by executed the following command:
```sh
fastlane action install_saucectl
```
-----------------------------------------------------------------------

# Example action

### Install latest version of saucectl
```ruby
lane :install_toolkit do
  install_saucectl
end 
```

### Install a specific version of saucectl
```ruby
lane :install_toolkit do
  install_saucectl(version: '0.86.0')
end 
```
