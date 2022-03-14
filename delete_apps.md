---
layout: page
title: Delete Sauce Labs apps
permalink: /delete-apps/
---

### Delete an App Storage File
Deletes the specified file from Sauce Storage.

## `region`
> Data Center you wish to query

| Required | ***true***         |
| Type     | ***String***       |
| Options  | ***us, eu***       |
___________________________________________________________________________
## `sauce_username`
> Your sauce labs username in order to authenticate requests

If this parameter is not set the plugin expects there to be an `SAUCE_USERNAME` environment variable set. 

| Required | ***false***        |
| Type     | ***String***       |
___________________________________________________________________________
## `sauce_access_key`
> Your sauce labs access key in order to authenticate requests

If this parameter is not set the plugin expects there to be an `SAUCE_ACCESS_KEY` environment variable set.

| Required | ***false***        |
| Type     | ***String***       |
___________________________________________________________________________
## `app_id`
> The application id from sauce labs storage

| Required | ***false***        |
| Type     | ***String***       |

____________________________________________________________________________
## `group_id`
> The group id for sauce labs storage

| Required | ***false***        |
| Type     | ***String***       |
____________________________________________________________________________

Example actions
### Delete by app_id
```ruby
    lane :delete_by_app_id do
      delete_from_storage({region: 'eu',
                           sauce_username: 'foo',
                           sauce_access_key: 'bar123',
                           app_id: '1235-1235-1235-1235-1235'
                          })
      end 
```
### Delete by group_id
```ruby
  lane :delete_by_group_id do
    delete_from_storage({region: 'eu',
                         sauce_username: 'foo',
                         sauce_access_key: 'bar123',
                         group_id: '123456789'
                        })
    end
```