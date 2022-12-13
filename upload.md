---
layout: default
title: Upload to Storage
nav_order: 4
---

# Upload action

With Sauce Labs Toolkit Fastlane Plugin you can automatically upload your apps to Sauce Labs storage using the `sauce_upload` action.

# Help
Information and help for the `sauce_upload` action can be printed out by executed the following command:
```sh
fastlane action sauce_upload
```
-----------------------------------------------------------------------


### Supported filetypes
At the time of writing the following filetypes can be uploaded to sauce storage:
 1. .apk 
 2. .aab
 3. .ipa 
 4. .zip

### Supported Data centers

| Data Center   | URL                                      |
|---------------|------------------------------------------| 
| us            | https://api.us-west-1.saucelabs.com/     | 
| eu            | https://api.eu-central-1.saucelabs.com/  |

---------------------------------------------------------------
