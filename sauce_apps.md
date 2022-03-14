---
layout: page
title: Sauce Labs applications
permalink: /apps/
---

### Get App Storage Files
Returns the set of files by specific app id that have been uploaded to Sauce Storage by the requester

## `platform`
> Device platform that you wish to query

| Required | ***true***         |
| Type     | ***String***       |
| Options  | ***ios, android*** |
___________________________________________________________________________

## `query`
> Any search term (such as build number or file name) by which you want to filter results

| Required | ***true***         |
| Type     | ***String***       |
___________________________________________________________________________

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

Example actions
```ruby
lane :get_apps do
          sauce_apps({platform: 'android',
                      query: 'test.apk',
                      region: 'eu',
                      sauce_username: 'foo',
                      sauce_access_key: 'bar123',
                     })
end

lane :get_apps do
  sauce_apps({platform: 'android',
              query: 'test.apk',
              region: 'eu'})
end

lane :get_apps do
  sauce_apps({platform: 'ios',
              query: 'test.app',
              region: 'eu',
              sauce_username: 'foo',
              sauce_access_key: 'bar123',
             })
end

lane :get_apps do
  sauce_apps({platform: 'android',
              query: 'test.apk', 
              region: 'eu'})
end 
```

Response
```json
{
    "items": [
        {
            "id": "1234-1234-1234-1234-1234",
            "owner": {
                "id": "1234-1234-1234-1234-1234",
                "org_id": "1234-1234-1234-1234-1234"
            },
            "name": "test.apk",
            "upload_timestamp": 1636368973,
            "etag": "1234-1234-1234-1234-1234",
            "kind": "android",
            "group_id": 111111,
            "description": null,
            "metadata": {
                "identifier": "com.test.apk",
                "name": "",
                "version": null,
                "is_test_runner": false,
                "icon": null,
                "version_code": null,
                "min_sdk": 24,
                "target_sdk": 29,
                "test_runner_class": ""
            },
            "access": {
                "team_ids": [
                    "1234-1234-1234-1234-1234"
                ],
                "org_ids": []
            },
            "sha256": "1234-1234-1234-1234-1234"
        }
    ],
    "links": {
        "prev": null,
        "next": null,
        "self": "?q=test.apk&kind=Android&page=1&per_page=25"
    },
    "page": 1,
    "per_page": 25,
    "total_items": 1
}
```
