---
layout: page
title: Install saucectl binary
permalink: /install/
---

# Install Sauce Labs toolkit
Install Sauce Labs framework agnostic test orchestrator saucectl to execute Espresso and XCUITest tests

# Help
Information and help for the `install_toolkit` action can be printed out by executed the following command:
```sh
fastlane action install_toolkit
```
-----------------------------------------------------------------------

# Example action

### Delete by app_id
```ruby
lane :install_toolkit do
    install_toolkit
end 
```
