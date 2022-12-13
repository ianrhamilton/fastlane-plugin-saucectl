---
layout: default
title: Get applications
nav_order: 7
---

# Get App Storage Files

Returns the set of files by specific app id that have been uploaded to Sauce Storage by the requester

# Help
Information and help for the `sauce_apps` action can be printed out by executed the following command:
```sh
fastlane action sauce_apps
```

---------------------------------------------------------------------------
## `platform`

| Required | Type     | Description                            | Options         |
|----------|----------|----------------------------------------|-----------------|
| `true`   | `String` | Device platform that you wish to query | `ios`,`android` |   

---------------------------------------------------------------------------
## `query`

| Required | Type     | Description                                                                             | 
|----------|----------|-----------------------------------------------------------------------------------------|
| `true`   | `String` | Any search term (such as build number or file name) by which you want to filter results |  

___________________________________________________________________________
## `region`

| Required | Type     | Description                   | Options    |
|----------|----------|-------------------------------|------------|
| `true`   | `String` | Data Center you wish to query | `us`, `eu` |

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

# Example actions

```ruby
lane :get_apps do
          sauce_apps(platform: 'android',
                     query: 'test.apk',
                     region: 'eu',
                     sauce_username: 'foo',
                     sauce_access_key: 'bar123')
end

lane :get_apps do
  sauce_apps(platform: 'android',
             query: 'test.apk',
             region: 'eu')
end

lane :get_apps do
  sauce_apps(platform: 'ios',
             query: 'test.app',
             region: 'eu',
             sauce_username: 'foo',
             sauce_access_key: 'bar123')
end

lane :get_apps do
  sauce_apps(platform: 'android',
             query: 'test.apk', 
             region: 'eu')
end 

```

<details>
<summary>Example Response</summary>
<pre>

```json
{
    "items": [
        {
            "id": "1234-1234-1234-1234-1234",
            "owner": {
                "id": "1234-1234-1234-1234-1234",
                "org_id": "1235-1236"
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
                  "1235-1236"
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
</pre>
</details>
