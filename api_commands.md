`api.rb`

Sends and returns JSON via a command line interface.

#### `infoInst`

```
# ./api.rb infoInst
{
  "platform":"Amazon AWS",
  "availability-zone":"eu-west-2a",
  "instance-type":"t2.large",
  "external-ip":"18.130.114.107",
  "internal-ip":"172.31.8.23",
  "hostname":"ip-172-31-8-23.eu-west-2.compute.internal"
}
```
#### Arguments

None

#### Returns

| Attribute           | Type     | Description                                       |
|---------------------|----------|---------------------------------------------------|
| `platform`          | `string` | Vendor of platform appliance is running on.       |
| `availability-zone` | `string` | Availability zone within vendor's cloud platform. |
| `instance-type`     | `string` | Instance type that appliance is running on.       |
| `external-ip`       | `string` | External Public IP address of appliance.          |
| `internal-ip`       | `string` | Internal Private IP address of appliance.         |
| `hostname`          | `string` | Hostname of appliance.                            |
|                     |          |                                                   |

#### `inetStat`

```
# ./api.rb inetStat
{
  "ping-google":true,
  "resolve-alces-software":true,
  "default-gateway":"172.31.0.1",
  "dns-servers":["172.31.0.2"],
  "search-domain":"eu-west-2.compute.internal"
}
```

#### Arguments

None

#### Returns

| Attribute                | Type              | Description                                                                                    |
|--------------------------|-------------------|------------------------------------------------------------------------------------------------|
| `ping-google`            | `boolean`         | `true` When 8.8.8.8 is responding, otherwise `false`.                                          |
| `resolve-alces-software` | `boolean`         | `true` When appliance can resolve `alces-software.com`, false when domain cannot be resolved. |
| `default-gateway`        | `string`          | IP Address of appliance's default gateway                                                      |
| `dns-servers`            | array of `string` | Array containing IP addresses of configured DNS servers.                                       |
| `search-domain`          | array of `string` | Array containing configured search domains.                                                    |

#### `extIp`

```
# ./api.rb extIp
{
  "external-ip":"18.130.114.107"
}
```
#### Arguments

None

#### Returns

| Attribute   | Type     | Description                              |
|-------------|----------|------------------------------------------|
| external-ip | `string` | Returns Appliance's external IP address. |


#### `intIp`

```
# ./api.rb intIp
{
  "internal-ip":"172.31.8.23"
}
```
#### Arguments

None

#### Returns

| Attribute   | Type     | Description                              |
|-------------|----------|------------------------------------------|
| internal-ip | `string` | Returns Appliance's internal IP address. |


#### `availabilityZone`

#### Arguments

None

#### Returns

| Attribute         | Type     | Description                                                                    |
|-------------------|----------|--------------------------------------------------------------------------------|
| availability-zone | `string` | Returns Appliance instance's availability zone within vendor's cloud platform. |

#### `instanceType`

#### Arguments

None

#### Returns

| Attribute     | Type     | Description                                         |
|---------------|----------|-----------------------------------------------------|
| instance-type | `string` | Returns instance type that Appliance is running on. |

#### `engMode`

#### Arguments

None

#### Returns

| Attribute | Type      | Description                                                                     |
|-----------|-----------|---------------------------------------------------------------------------------|
| status    | `boolean` | `true` If command completed successfully, `false` if system returned an error.  |

#### `userCreate`

```
# ./api.rb userCreate '{"user-name":"foobar","full-name":"Foobly Barr"}'
{
  "user-name":"foobar",
  "status":true
}
```

#### Arguments

| Attribute | Type     | Description                                  |
|-----------|----------|----------------------------------------------|
| user-name | `string` | System username to be created with no spaces |
| full-name | `string` | User's full name                             |

#### Returns

| Attribute | Type      | Description                                                                 |
|-----------|-----------|-----------------------------------------------------------------------------|
| user-name | `string`  | System username created - optional, only if command completed successfully. |
| status    | `boolean` | `true` If command completed successfully, `false` if command failed.        |

#### `userSetKey`

Set a new SSH key for a system user.

```
# ./api.rb userSetKey '{"user-name":"foobar","key":"ssh-key 1234abcd foobar@appliance"}'
{
  "user":"foobar",
  "status":true
}
```

#### Arguments

| Attribute | Type     | Description                      |
|-----------|----------|----------------------------------|
| user-name | `string` | System user to set new key for.  |
| key       | `string` | User's SSH key to be configured. |

#### Returns

| Attribute | Type      | Description                                                                              |
|-----------|-----------|------------------------------------------------------------------------------------------|
| user-name | `string`  | System user that new key was set for - optional, only if command completed successfully. |
| status    | `boolean` | `true` If command completed successfully, `false` if command failed.                     |

#### `userGetList`

```
# ./api.rb userGetList
{
  "users":["operator(uid=11)","bob(uid=1002)","test(uid=1003)","foobar(uid=1004)"]
}
```

#### Arguments

None

#### Returns

| Attribute | Type              | Description                          |
|-----------|-------------------|--------------------------------------|
| users     | array of `string` | Array of user-name with system UIDs. |

#### `userSetPasswd`

```
# ./api.rb userSetPasswd '{"user-name":"bob","passwd":"mYsECurEPAsSW0rD!"}'
{
  "user-name":"bob","status":true
}
```
#### Arguments

| Attribute | Type     | Description                          |
|-----------|----------|--------------------------------------|
| user-name | `string` | System user to set new password for. |
| password  | `string` | Crypted password to be set.          |

#### Returns

| Attribute | Type      | Description                                                                                   |
|-----------|-----------|-----------------------------------------------------------------------------------------------|
| user-name | `string`  | System user that new password was set for - optional, only if command completed successfully. |
| status    | `boolean` | `true` If command completed successfully, `false` if command failed.                          |

#### `userDelete`

```
# ./api.rb userDelete '{"user-name":"bob","delete":true}'
{
  "user-name":"bob","status":true
}
```

#### Arguments

| Attribute | Type      | Description                          |
|-----------|-----------|--------------------------------------|
| user-name | `string`  | System user to be deleted.           |
| delete    | `boolean` | `true` to confirm password deletion. |

#### Returns

| Attribute | Type      | Description                                                                      |
|-----------|-----------|----------------------------------------------------------------------------------|
| user-name | `string`  | System user that was deleted - optional, only if command completed successfully. |
| status    | `boolean` | `true` If command completed successfully, `false` if command failed.             |

#### `shutdown`

```
# ./api.rb shutdown '{"shutdown":true}'
{
  "status":true
}
```
#### Arguments

| Attribute | Type      | Description                                                          |
|-----------|-----------|----------------------------------------------------------------------|
| shutdown  | `boolean` | `true` to confirm shutdown.                                          |


#### Returns

| Attribute | Type      | Description                                                          |
|-----------|-----------|----------------------------------------------------------------------|
| status    | `boolean` | `true` If command completed successfully, `false` if command failed. |
