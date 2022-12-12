---
layout: default
title: Delete apps from storage
nav_order: 8
---

# Delete App Storage File

Deletes a specified file from Sauce Labs Storage.

# Help
Information and help for the `delete_from_storage` action can be printed out by executed the following command:
```sh
fastlane action delete_from_storage
```
-----------------------------------------------------------------------

## `region`

| Required | Type     | Description                   | 
|----------|----------|-------------------------------|
| `true`   | `String` | Data Center you wish to query |

---------------------------------------------------------------------------------
## `sauce_username`

| Required  | Type     | Description                                                | 
|-----------|----------|------------------------------------------------------------|
| `false` | `String` | Your sauce labs username in order to authenticate requests |

**If this parameter is not set the plugin expects there to be an `SAUCE_USERNAME` environment variable set.**

___________________________________________________________________________
## `sauce_access_key`

| Required | Type     | Description                                                  | 
|----------|----------|--------------------------------------------------------------|
| `false`  | `String` | Your sauce labs access key in order to authenticate requests |

**If this parameter is not set the plugin expects there to be an `SAUCE_ACCESS_KEY` environment variable set.**

__________________________________________________________________________
## `app_id`

| Required | Type     | Description                                | 
|----------|----------|--------------------------------------------|
| `false`  | `String` | The application id from sauce labs storage |

____________________________________________________________________________
## `group_id`

| Required | Type     | Description                         | 
|----------|----------|-------------------------------------|
| `false`  | `String` | The group id for sauce labs storage |

____________________________________________________________________________

# Example actions

### Delete by app_id
```ruby
    lane :delete_by_app_id do
      delete_from_storage(region: 'eu',
                          sauce_username: 'foo',
                          sauce_access_key: 'bar123',
                          app_id: '1235-1235-1235-1235-1235')
      end 
```

---------------------------------------------------------------------
### Delete by group_id
```ruby
  lane :delete_by_group_id do
    delete_from_storage(region: 'eu',
                        sauce_username: 'foo',
                        sauce_access_key: 'bar123',
                        group_id: '123456789')
    end
```

---------------------------------------------------------------------
