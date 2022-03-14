---
layout: page
title: Execute tests
permalink: /execute-tests/
---

### Install sauce labs toolkit binary
Execute automated tests on sauce labs platform via saucectl binary

## `sauce_username`
> Your sauce labs username in order to authenticate requests

If this parameter is not set the plugin expects there to be an `SAUCE_USERNAME` environment variable set.

| Required | ***false***        |
| Type     | ***String***       |

## `sauce_access_key`
> Your sauce labs access key in order to authenticate requests

If this parameter is not set the plugin expects there to be an `SAUCE_ACCESS_KEY` environment variable set.

| Required | ***false***        |
| Type     | ***String***       |

If you have environment variables set for username and access key

```ruby
    sauce_runner
```

Set authentication parameters
```ruby
lane :execute_tests do
    sauce_runner(sauce_username: 'myUsername',
                 sauce_access_key: 'myAccessKey')
end 

```


