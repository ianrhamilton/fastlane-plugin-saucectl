---
layout: default
title: Execute tests
nav_order: 5
---

### Install sauce labs toolkit binary
Execute automated tests on sauce labs platform via saucectl binary

## `sauce_username`

| Required | Type     | Description                                                | 
|----------|----------|------------------------------------------------------------|
| `false`  | `String` | Your sauce labs username in order to authenticate requests |

**If this parameter is not set the plugin expects there to be an `SAUCE_USERNAME` environment variable set.**

___________________________________________________________________________
## `sauce_access_key`

| Required | Type     | Description                                                  | 
|----------|----------|--------------------------------------------------------------|
| `false`  | `String` | Your sauce labs access key in order to authenticate requests |

**If this parameter is not set the plugin expects there to be an `SAUCE_ACCESS_KEY` environment variable set.**

__________________________________________________________________________
# Example action

```ruby
lane :execute_tests do
  sauce_runner
end

```

### Set authentication parameters
```ruby
lane :execute_tests do
    sauce_runner(sauce_username: 'myUsername',
                 sauce_access_key: 'myAccessKey')
end 

```
__________________________________________________________________